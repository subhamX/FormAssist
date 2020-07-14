const fs = require('fs');
const readline = require('readline');
const { google } = require('googleapis');
const config = require('./config');

var admin = require("firebase-admin");

var serviceAccount = require("./service-account.json");

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: config.databaseURL
});

const db = admin.firestore();


const SCOPES = [
    'https://www.googleapis.com/auth/spreadsheets'
];

const TOKEN_PATH = 'token.json';


fs.readFile('./credentials.json', async (err, content) => {
    if (err) return console.log('Error loading client secret file:', err);
    authorize(JSON.parse(content), addBankForms);
});


function authorize(credentials, callback) {
    const { client_secret, client_id, redirect_uris } = credentials.installed;
    const oAuth2Client = new google.auth.OAuth2(
        client_id, client_secret, redirect_uris[0]);

    fs.readFile(TOKEN_PATH, (err, token) => {
        if (err) return getNewToken(oAuth2Client, callback);
        oAuth2Client.setCredentials(JSON.parse(token));
        callback(oAuth2Client);
    });
}


function getNewToken(oAuth2Client, callback) {
    const authUrl = oAuth2Client.generateAuthUrl({
        access_type: 'offline',
        scope: SCOPES,
    });
    console.log('Authorize this app by visiting this url:', authUrl);
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout,
    });
    rl.question('Enter the code from that page here: ', (code) => {
        rl.close();
        oAuth2Client.getToken(code, (err, token) => {
            if (err) return console.error('Error while trying to retrieve access token', err);
            oAuth2Client.setCredentials(token);
            // Store the token to disk for later program executions
            fs.writeFile(TOKEN_PATH, JSON.stringify(token), (err) => {
                if (err) return console.error(err);
                console.log('Token stored to', TOKEN_PATH);
            });
            callback(oAuth2Client);
        });
    });
}





let bankFormsMap = config.bankFormsMap;



async function addBankForms(auth) {
    const sheets = google.sheets({ version: 'v4', auth });
    let bankForms = Object.entries(bankFormsMap);

    for (var j = 0; j < bankForms.length; j++) {
        let bankFormUniqueId = bankForms[j][0];
        console.log(`Adding data into ${bankFormUniqueId} Collection`);
        let range = bankForms[j][1];
        await new Promise((resol, rej) => {
            sheets.spreadsheets.values.get({
                spreadsheetId: config.spreadsheetID,
                range: range,
            }, async (err, res) => {
                if (err) return console.log('The API returned an error: ' + err);
                const rows = res.data.values;
                if (rows.length) {
                    // Print columns A and E, which correspond to indices 0 and 4.
                    await new Promise(async (resolve, reject) => {
                        for (var index in rows) {
                            var row = rows[index];
                            var sectionDocId = row[0];
                            var fieldDocId = row[2];
                            if (!fieldDocId) {
                                continue;
                            }
                            console.log(`Finding: Field: ${fieldDocId} into Section: ${sectionDocId} in master_fields`);
                            // Loading data from master_fields
                            let doc = await db.collection('master_fields').doc(sectionDocId.replace(' ', '')).collection('section').doc(fieldDocId.replace(' ', '')).get();
                            if (!doc.exists) {
                                console.log('errr');
                                reject(100);
                            }

                            console.log(doc.data());
                            console.log(`Adding: Field: ${fieldDocId} into Section: ${sectionDocId} into ${bankFormUniqueId}`);
                            // Need to add form_name and section_name
                            let res = await db.collection('bank_forms').doc(bankFormUniqueId).collection('section').doc(sectionDocId).collection('section').doc(fieldDocId).set(doc.data());
                            console.log(res);
                        }
                        await addBankFormMetaData();
                        await addSectionNamesToBankForm();
                        resolve(100);
                        resol(100);
                    });

                } else {
                    console.log('No data found.');
                }
            });
        });
    }
}



// Adding Form Metadata to Bank Form Document
async function addBankFormMetaData() {
    let bankIdMetaDataMap = config.bankIdMetaDataMap;
    let forms = Object.entries(bankIdMetaDataMap);
    for (var form of forms) {
        let res = await db
            .collection('bank_forms')
            .doc(form[0]).set({ "form_name": form[1]['form_name'], "agent_email": form[1]['agent_email'] }, { merge: true });
        console.log(res);
    }
}


// Adding Form Metadata to Bank Form Document
async function addSectionNamesToBankForm() {
    let bankIdMetaDataMap = config.bankIdMetaDataMap;
    let sectionIdNamesMap = config.sectionIdNamesMap;
    let forms = Object.entries(bankIdMetaDataMap);
    let sections = Object.entries(sectionIdNamesMap);
    for (var form of forms) {
        for (var section of sections) {
            let res = await db
                .collection('bank_forms')
                .doc(form[0]).collection('section').doc(section[0]).set({"section_name": section[1]}, {merge: true});
            console.log(res);
            // console.log(form[0], section)
        }
    }
}
