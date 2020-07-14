/**
 *
 * https://developers.google.com/sheets/api/quickstart/nodejs
 */

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
    authorize(JSON.parse(content), addMasterFieldsToDB);
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




async function addMasterFieldsToDB(auth) {
    const sheets = google.sheets({ version: 'v4', auth });
    sheets.spreadsheets.values.get({
        spreadsheetId: config.spreadsheetID,
        range: config.masterFieldRange,
    }, async (err, res) => {
        if (err) return console.log('The API returned an error: ' + err);
        console.log("Adding data into Master Fields Collection");
        const rows = res.data.values;
        if (rows.length) {
            // Print columns A and E, which correspond to indices 0 and 4.
            await new Promise(async (resolve, reject) => {
                for (var index in rows) {
                    var row = rows[index];
                    var fieldsArray = row[0]
                    var sectionDocId = row[1];
                    var fieldDocId = row[2];
                    var tag = row[3];
                    var degree = parseInt(row[4]);
                    var type = row[5];
                    var hint = row[6] ? row[6] : '';
                    if (!fieldDocId) {
                        continue;
                    }
                    console.log(`Adding: field ${fieldDocId} into section ${sectionDocId}`);
                    
                    // Need to add form_name and section_name
                    
                    let fieldDoc = await db.collection('master_fields').doc(sectionDocId).collection('section').doc(fieldDocId).set({
                        "degree": degree,
                        "fields" : fieldsArray,
                        "hint": hint,
                        "tag" : tag,
                        "type" :type,
                    });
                    console.log(fieldDoc);
                }
                await addSectionNames();
                resolve(100);
            });
        } else {
            console.log('No data found.');
        }
    });
}




// Adding Names to Sections
async function addSectionNames() {
    let sectionIdNamesMap = config.sectionIdNamesMap;
    let sections = Object.entries(sectionIdNamesMap);
    for(var section of sections){
        let res = await db.collection('master_fields').doc(section[0]).set({"section_name": section[1]}, {merge: true});
        console.log(res);
    }
}




function buildFieldsArray(auth, fieldsArray, pos) {
    const sheets = google.sheets({ version: 'v4', auth });
    return new Promise((resolve, reject) => {
        sheets.spreadsheets.values.update({
            spreadsheetId: config.spreadsheetID,
            range: `Sheet6!A${pos}`,
            valueInputOption: "RAW",
            resource: {
                "values": [[`[${fieldsArray.toString()}]`]]
            },
        }, (err, result) => {
            console.log("comple");
            if (err) {
                // Handle error
                console.log(err);
            } else {
                console.log('%d cells updated.', result.updatedCells);
            }
            resolve(100);
        })
    });
}