"use strict";
const {SRT, SRTServer, AsyncSRT, SRTReadStream, SRTSockOpt} = require(
    "@eyevinn/srt",
);
var Kafka = require("node-rdkafka");
const {fetchConfigByKey,fetchSessionIdByResourceAndUser, updateSessionToUsed} = require('./getConfigByKey')

const asyncSrtServer = new SRTServer(
    Number(process.env.SERVER_PORT),
    "0.0.0.0",
);
asyncSrtServer.on("connection", (connection) => {
    onClientConnected(connection);
});

async function onClientConnected(connection) {
    console.log("Got new connection:", connection.fd);
    const fd = {
        fd: connection.fd,
        readerWriter: connection.getReaderWriter(),
    };
    const asyncSrt = new AsyncSRT();
    console.log(SRT.SRTO_STREAMID)
    let streamId = await asyncSrt.getSockOpt(fd.fd, SRT.SRTO_STREAMID);
    console.log(`streamId ${streamId}`)

    let username = streamId.substring(streamId.indexOf("u="));
    username = username.substring(2, username.indexOf(","));
    console.log(`username=${username}`)

    let sessionId = streamId.substring(streamId.indexOf("s="));
    sessionId = sessionId.substring(2, sessionId.indexOf(","));
    console.log(`sessionId=${sessionId}`)

    let requestedResource = streamId.substring(streamId.indexOf('r='));
    requestedResource = requestedResource.substring(2, requestedResource.indexOf(','));//skip r=
    console.log(`requestedResource ${requestedResource}`)

    let rows = await  fetchSessionIdByResourceAndUser(sessionId,username,requestedResource,false);
    console.log(`row: ${JSON.stringify(rows)}`);
    if(rows.length < 1){
        await connection.close();//todo close with some error so client wont reconnect
    } else {
        updateSessionToUsed(sessionId,username,requestedResource)
    }

    // Read from the librdtesting-01 topic... note that this creates a new stream on each call!
    var stream = Kafka.KafkaConsumer.createReadStream(
        {
            //https://github.com/confluentinc/librdkafka/blob/v2.0.2/CONFIGURATION.md
            "metadata.broker.list": `${process.env.KAFKA_BROKER_LIST}`,
            "group.id": `edge-${process.env.HOSTNAME != null && process.env.HOSTNAME != undefined ? process.env.HOSTNAME : process.env.SERVER_ID}-${connection.fd}-${Date.now()}`, //edge-2 no need
            "socket.keepalive.enable": true,
            "enable.auto.commit": true,
            "isolation.level": "read_committed",
            // "isolation.level": "read_uncommitted",
            "auto.offset.reset": "latest",
        },
        {},
        {
            topics: requestedResource,//"livestream1"
            waitInterval: 0,
            objectMode: false,
        },
    );
    // Robust handling of SRT connection errors
    connection.on('error', (err) => {
        console.error(`SRT Connection Error for FD ${connection.fd}:`, err);
        stream.destroy()
        stream.consumer.disconnect();
        connection.close();
    });
    stream.on("error", function (err) {
        console.error('Kafka Consumer Stream Error:', err);
        if (err) {
            console.log(err);
            stream.destroy()
            stream.consumer.disconnect();
            connection.close();
        }
    });
// Handling Kafka consumer specific errors
    stream.consumer.on("event.error", function (err) {
        console.error('Kafka Consumer Error:', err);
        if (err) {
            console.log(err);
            stream.destroy()
            stream.consumer.disconnect();
            connection.close();
        }
    });
    stream.on("data", function (chunk) {
        if (chunk === null || chunk === undefined) {
            console.error('Cannot send data: chunk is null or undefined.');
            return;
        }

        let buffer;
        // Check if chunk is already a Buffer
        if (Buffer.isBuffer(chunk)) {
            buffer = chunk;
        } else {
            buffer = Buffer.from(chunk, "utf8");
        }
        // Check if the buffer is empty
        if (buffer.length === 0) {
            console.log('Skipping send: buffer is empty.');
            return;
        }
        fd.readerWriter.writeChunks(buffer);
    });

    stream.consumer.on("event.error", function (err) {
        console.log(err);
    });

    connection.on("data", async () => {
        console.log(`data from ${connection.fd}`);
        if (!connection.gotFirstData) {
            onClientData();
        }
    });
    connection.on("closing", async () => {
        connection.close();
    });
    connection.on("closed", async () => {
        console.log(`closed ${connection.fd}`);
        stream.destroy()
        stream.consumer.disconnect();
        connection.close();
    });

    // const reader = connection.getReaderWriter();
    async function onClientData() {
    }
}

asyncSrtServer.create().then(async (s) => {
    // Set encryption options here
    let passphrase = process.env.SRT_PASSPHRASE; // Ensure you have this environment variable set
    let keyLength = 16; // 128 bits. You can also use 24 for 192 bits or 32 for 256 bits
    try{
        const result =  await fetchConfigByKey('edge_passphrase')
        if(result.length > 0 && result[0].value){
            passphrase = result[0].value;
        }
    } catch (err){
        console.error(`failed fetching config will default to env passphrase`, err)
    }
    try{
        const result =  await fetchConfigByKey('edge_keyLength')
        if(result.length > 0 && result[0].value){
            keyLength = Number(result[0].value);
        }
    } catch (err){
        console.error(`failed fetching config will default to hardcoded keylength`, err)
    }
    // // Check if passphrase is set, then enable encryption
    if (passphrase && passphrase.length > 0) {
        await s.setSocketFlags([SRT.SRTO_PASSPHRASE,SRT.SRTO_PBKEYLEN], [passphrase,keyLength]);
    }

    s.open();
}).then(() => {
    console.log(
        `listening server ${process.env.SERVER_PORT}. server id: ${process.env.SERVER_ID}`,
    );
}).catch((err) => {
    console.log(`failed to start server ${err}`);
});


const net = require('net');

const HEALTH_CHECK_PORT = process.env.HEALTH_CHECK_PORT || 9999; // Choose an appropriate port

const healthCheckServer = net.createServer((socket) => {
    console.log("Received health check request");
    socket.end('OK\n'); // Respond with OK and close the connection
});

healthCheckServer.listen(HEALTH_CHECK_PORT, () => {
    console.log(`Health check server listening on port ${HEALTH_CHECK_PORT}`);
});