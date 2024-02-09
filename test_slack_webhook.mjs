const https = require('https');
const url = require('url');

// Replace YOUR_SLACK_WEBHOOK_URL with your actual Slack webhook URL
const SLACK_WEBHOOK_URL = new IncomingWebhook(process.env.SLACK_WEBHOOK_URL);

exports.handler = async (event) => {
    const message = JSON.stringify({
        text: "Hello, Slack! This is a test message from my AWS Lambda function.",
    });

    const slackUrl = url.parse(SLACK_WEBHOOK_URL);
    const options = {
        hostname: slackUrl.hostname,
        port: 443,
        path: slackUrl.pathname,
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Content-Length': Buffer.byteLength(message),
        },
    };

    return new Promise((resolve, reject) => {
        const req = https.request(options, (res) => {
            console.log(`STATUS: ${res.statusCode}`);
            res.setEncoding('utf8');
            res.on('data', (chunk) => {
                console.log(`BODY: ${chunk}`);
            });
            res.on('end', () => {
                resolve('Message sent to Slack successfully!');
            });
        });

        req.on('error', (e) => {
            console.error(`problem with request: ${e.message}`);
            reject(e);
        });

        // write data to request body
        req.write(message);
        req.end();
    });
};
