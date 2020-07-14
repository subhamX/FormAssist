const functions = require('firebase-functions');
const express = require('express');
const admin = require('firebase-admin');
const cors = require('cors');
const path = require('path');
const os = require('os');
const engines = require('consolidate');
const nodemailer = require('nodemailer');
require('dotenv').config();

let app = express();

app.engine('hbs', engines.handlebars);
app.set('views', './views');
app.set('view engine', 'hbs');

admin.initializeApp(functions.config().firebase);

let db = admin.firestore();
let cloudBucket = admin.storage().bucket();



app.use(express.json());
app.use(cors({ origin: true }));


// Helper Function To get current saved data of user
async function getData(uid, formId) {
    let data = [];
    let formRef = db.collection('forms').doc(uid).collection('userform').doc(formId);
    let form = await formRef.get();
    let formName = form.data()["form_name"];
    let bankFormName = form.data()["bank_form_name"];
    let sections = await formRef.collection('section').get();
    await Promise.all(sections.docs.map(async (section) => {
        let localData = [];
        let fields = await formRef.collection('section').doc(section.id).collection('fields').get();
        await Promise.all(fields.docs.map(async (field) => {
            let value = field.data()["value"] ? field.data()["value"] : "NO_VAL"
            localData.push({ "tag": field.data()["tag"], "value": value });
        }));
        data.push({
            "section_name": section.data()["section_name"],
            "fields": localData,
        });
    }));
    return { sections: data, formName, bankFormName, form };
}

// Handles Form Viewing
app.get('/forms/fa/:uniqueSlug', async (req, res) => {
    try {
        let uniqueSlug = req.params["uniqueSlug"];
        let doc = await db.collection('adminlinks').doc(uniqueSlug).get();
        if (doc.exists) {
            let formId = doc.data()["form_id"];
            let uid = doc.data()["uid"];
            console.log(formId);
            let statusDoc = await db.collection('links').doc(uid).collection('sharedlinks').doc(formId).get();
            let status = statusDoc.data()["isActive"];
            if (status) {
                let { sections, formName, bankFormName } = await getData(uid, formId);
                res.render('index', { sections, formName, bankFormName });
            } else {
                console.log(`Form is inactive: ${err}`);
                res.redirect("/404.html");
            }
        } else {
            console.log(`No Form with this uid is shared!`);
            res.redirect("/404.html");
        }

    } catch (err) {
        console.log(`Error: ${err}`);
        res.redirect("/404.html");
    }
});

// {form_id} {uid} {method} and {email}
app.post('/exportform/', async (req, res) => {
    let formId = req.body["form_id"];
    let formName = req.body["form_name"];
    let formType = req.body["form_type"];
    let uid = req.body["uid"];
    let method = req.body["method"];
    let email = req.body["email"];
    console.log(`${method}`);
    try {
        if (method === 3) {
            // Create Shareable Link
            let uniqueSlug = uid.slice(3, 8) + '_' + parseInt(Math.random() * 1000) + '_' + formId.slice(5) + parseInt(Math.random() * 1000);

            let doc = await db.collection('links').doc(uid).collection('sharedlinks').doc(formId).get();
            // If already shared then share the same link.'
            if (!doc.exists) {
                await db.collection('links').doc(uid).collection('sharedlinks').doc(formId).set({ "name": formName, "isActive": true, "slug": uniqueSlug, "type": formType })
                await db.collection('adminlinks').doc(uniqueSlug).set({ "uid": uid, "form_id": formId, "slug": uniqueSlug, "generation_time": new Date() });
            } else {
                uniqueSlug = doc.data()["slug"];
            }
            res.send({ "error": false, "url": uniqueSlug });
        } else {
            let { sections: data, formName, bankFormName, form } = await getData(uid, formId);
            let resultText = makeCSV(data);
            resultText = `Form Name, ${formName}\n\n` + resultText;
            resultText = `Form Type, ${bankFormName}\n\n` + resultText;
            let currDate = Date.now().toString();
            let fileName;
            let response;
            if (method === 2) {
                // CSV
                fileName = `${form.id}_${currDate}.csv`
            } else {
                fileName = `${form.id}_${currDate}.xlsx`;
            }
            await writeToFile(fileName, resultText);

            let subject = 'Your FormAssist export is ready';
            let message = `Greetings from <b>Form Assist<b/>,<br> <br>Thank you for using our app to digitally generate bank forms and be a part of the Digital India. Here is your bank form in ${method === 2 ? "CSV" : "Excel"} format.<br> <br> If you have any questions related to the form, please feel free to contact us. Hope you enjoyed using our app. <br> <br>Sincerely Team Form Assist`;
            const tempFilePath = path.join(os.tmpdir(), fileName);
            await cloudBucket.file(fileName).download({ destination: tempFilePath });
            response = await sendEmail(email, subject, message, tempFilePath, `${method === 2 ? formName + ".csv" : formName + ".xlsx"}`);
            await db.collection('exports').doc(uid).collection('hanuman').add(response);
            console.log(`${fileName} is Exported Successfully`);
            res.send({ "error": "false" });
        }
    } catch (err) {
        console.log(`Error: ${err}`);
        res.send({ "error": "true" });

    }
});

// Update the value in /users/{uid}/data/{section_name}/fields/{doc_id}
exports.helloWorld = functions.firestore
    .document('/forms/{uid}/userform/{form_id}/section/{section_id}/fields/{doc_id}')
    .onUpdate(async (change, context) => {
        if (change.after.data()["value"] !== change.before.data()["value"]) {
            let uid = context.params.uid;
            let formId = context.params.form_id;
            let sectionId = context.params.section_id;
            let docId = context.params.doc_id;
            change.after.data();
            console.log(`changes in ${formId} by ${uid} user, triggered! || AFTER VAL - ${change.after.data().value} || BEFORE VAL - ${change.before.data().value}`);
            let docRef = db.collection('users').doc(uid).collection('data').doc(sectionId).collection('fields').doc(docId);
            await docRef.set(change.after.data(), { merge: true });
        }
    });

// Whenever a new document i
exports.newFun = functions.firestore
    .document('/forms/{uid}/userform/{form_id}/section/{section_id}/fields/{doc_id}')
    .onCreate(async (snapshot, context) => {
        let uid = context.params.uid;
        let formId = context.params.form_id;
        let sectionId = context.params.section_id;
        let docId = context.params.doc_id;
        if (sectionId !== 'others') {
            let doc = await db.collection('users').doc(uid).collection('data').doc(sectionId).collection('fields').doc(docId).get();
            if (doc.exists) {
                console.log(`creation in ${formId} by ${uid} user, triggered! || AFTER VAL - ${doc.data().value} || BEFORE VAL - ${snapshot.data().value}`);
                snapshot.ref.set({ value: doc.data().value }, { merge: true });
            } else {
                console.log(`creation in ${formId} by ${uid} user, triggered! || NO CHANGE || BEFORE VAL - ${snapshot.data().value}`);
            }
        } else {
            console.log(`creation in ${formId} by ${uid} user, triggered! || NO CHANGE || SECTION - others`);

        }

    });

// Function Creates collections for the user
exports.onNewUserFun = functions.auth.user().onCreate(async (user) => {
    try {
        let uid = user.uid;
        await db.doc(`users/${uid}/data/residential_address`).set({ 'section_name': 'CURRENT ADDRESS' });
        await db.doc(`users/${uid}/data/permanent_address`).set({ 'section_name': 'PERMANENT ADDRESS' });
        await db.doc(`users/${uid}/data/personal_details`).set({ 'section_name': 'PERSONAL DETAILS' });
        await db.doc(`users/${uid}/data/financial_details`).set({ 'section_name': 'INCOME DETAILS' });
        await db.doc(`users/${uid}/data/office_details`).set({ 'section_name': 'OFFICE DETAILS' });
        await db.doc(`users/${uid}/data/loan_details`).set({ 'section_name': 'LOAN DETAILS' });
        await db.doc(`users/${uid}/data/employment_income_details`).set({ 'section_name': 'EMPLOYMENT DETAILS' });
        await db.doc(`users/${uid}/data/business_self_employed`).set({ 'section_name': 'BUSINESS DETAILS' });
        await db.doc(`users/${uid}/data/property_details`).set({ 'section_name': 'PROPERTY DETAILS' });
        await db.doc(`users/${uid}/data/others`).set({ 'section_name': 'OTHERS' });
    } catch (err) {
        console.log(`Error Occured! ${err}`);
    }
})

// functions.auth.onCreate
app.post('/copybankform/', async (req, res) => {
    try {
        let uid = req.body["uid"];
        let formName = req.body["form_name"];
        let bankFormName = req.body["bank_form_name"];
        let bankFormId = req.body["bank_form_id"];
        console.log(`${uid} ${formName} ${bankFormName} ${bankFormId}`);
        let userFormRef = db.collection('forms').doc(uid).collection('userform');
        let sectionRef = db.collection(`/bank_forms/${bankFormId}/section/`);

        let userForm = await userFormRef.add({ "form_name": formName, "bank_form_name": bankFormName });
        console.log(`userFormRef: ${userForm.id}`);

        console.log(`FORM NAME ${formName}AND BANK FORM NAME ${bankFormName} UPDATED!`);

        let sections = await sectionRef.get();

        // Traversing All Sections

        await Promise.all(sections.docs.map(async (section) => {
            let sectionId = section.id;
            console.log(section.data());
            let sectionName = section.data()['section_name'] ? section.data()['section_name'] : 'NO_NAME';
            await userFormRef
                .doc(userForm.id)
                .collection('section')
                .doc(sectionId)
                .set({
                    "section_name": sectionName,
                });
            console.log(`Section Name: ${sectionName}`);

            let fields = await sectionRef.doc(sectionId).collection('section').get();

            // Traversing All Fields and adding it to userForm
            await Promise.all(fields.docs.map(async (field) => {
                console.log(field);
                await userFormRef
                    .doc(userForm.id)
                    .collection('section')
                    .doc(sectionId)
                    .collection('fields')
                    .doc(field.id)
                    .set({ ...field.data(), "value": "" });
            }));
        }));
        console.log('Success! Jai Shree Ram')
        res.json({ 'formId': userForm.id, 'error': false });
    } catch (err) {
        console.log(`ERROR occured ${err}`);
        res.json({ 'error': true });
    }
});

// Exporting HTTP cloud function
exports.api = functions.https.onRequest(app);


function makeCSV(sections) {
    let resultCSV = '';
    sections.forEach((section) => {
        resultCSV += `Section Name, ${section["section_name"]}\n`;
        let fields = section["fields"];
        fields.forEach((field) => {
            resultCSV += `${field["tag"]}, ${field["value"]}\n`;
        });
        resultCSV += '\n';
    });
    return resultCSV;
}


function sendEmail(email, subject, messageText, filePath, fileName) {
    try {
        let transporter = nodemailer.createTransport({
            service: 'gmail',
            auth: {
                user: 'teamformassist@gmail.com',
                pass: process.env.PASSWORD
            }
        });
        const mailOptions = {
            from: 'Team Form Assist<teamformassist@gmail.com>',
            to: email,
            subject: subject,
            attachments: [
                {   // utf-8 string as an attachment
                    path: `${filePath}`,
                    filename: fileName
                },
            ],
            html: messageText
        };

        return new Promise((res, rej) => {
            transporter.sendMail(mailOptions, (erro, info) => {
                console.log(info);
                if (erro) {
                    console.log(erro);
                    console.log(`ERROR: ${erro}`);
                    rej(info);
                } else {
                    res(info);
                    console.log("MAIL SENT");
                }
            });
        })
    } catch (err) {
        print(err);
        return err;
    }
}


async function writeToFile(fileName, result) {
    try {
        await cloudBucket.file(fileName).save(result);
    } catch (err) {
        console.log(err);
    }
}