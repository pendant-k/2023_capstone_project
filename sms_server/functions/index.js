const express = require("express");
const functions = require("firebase-functions");
const axios = require("axios");
const CryptoJS = require("crypto-js");

const app = express();

const serviceKey = process.env.SERVICE_KEY;
const secretKey = process.env.SECRET_KEY;
const accessKey = process.env.ACCESS_KEY;

app.get("/", (req, res) => {
    const date = Date.now().toString();
    const method = "POST";
    const space = " ";
    const newLine = "\n";
    const url = `https://sens.apigw.ntruss.com/sms/v2/services/${serviceKey}/messages`;
    const url2 = `/sms/v2/services/${serviceKey}/messages`;
    const hmac = CryptoJS.algo.HMAC.create(CryptoJS.algo.SHA256, secretKey);

    hmac.update(method);
    hmac.update(space);
    hmac.update(url2);
    hmac.update(newLine);
    hmac.update(date);
    hmac.update(newLine);
    hmac.update(accessKey);

    const hash = hmac.finalize();
    const signature = hash.toString(CryptoJS.enc.Base64);
    functions.logger.info("Receive Request from Rasberry Pi");
    axios({
        method: method,
        url: url,
        headers: {
            "Contenc-type": "application/json; charset=utf-8",
            "x-ncp-iam-access-key": accessKey,
            "x-ncp-apigw-timestamp": date,
            "x-ncp-apigw-signature-v2": signature,
        },
        data: {
            type: "SMS",
            contentType: "COMM",
            countryCode: "82",
            from: "01084770706",
            content: "내용",
            messages: [
                {
                    to: "01030509283",
                    content: "[Accident Notification]\nCheck Dashcam in app",
                },
            ],
        },
    })
        .then(() => {
            res.status(200).send("success");
        })
        .catch((err) => {
            functions.logger.error(err);
            res.status(400).send("request failed");
        });
});

exports.app = functions.https.onRequest(app);
