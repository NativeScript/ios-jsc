var ws = require("ws");
var net = require("net");
var util = require('util');
var stream = require("stream");

util.inherits(PacketStream, stream.Transform);
function PacketStream(opts) {
    stream.Transform.call(this, opts);
}

PacketStream.prototype._transform = function(packet, encoding, done) {
    while (packet.length > 0) {
        if (!this.buffer) {
            // read length
            var length = packet.readInt32BE(0);
            this.buffer = new Buffer(length);
            this.offset = 0;
            packet = packet.slice(4);
        }

        packet.copy(this.buffer, this.offset);
        var copied = Math.min(this.buffer.length - this.offset, packet.length);
        this.offset += copied;
        packet = packet.slice(copied);

        if (this.offset === this.buffer.length) {
            this.push(this.buffer);
            this.buffer = undefined;
        }
    }
    done();
};

var server = ws.createServer({
    port: 8080
});
server.on("connection", function(webSocket) {
    console.info("Frontend client connected.");

    var deviceSocket = net.connect(18182);
    var packets = new PacketStream();
    deviceSocket.pipe(packets);

    packets.on("data", function(buffer) {
        //console.log("DEVICE " + buffer.toString("utf8"));
        webSocket.send(buffer.toString("utf16le"), function(error) {
            if (error) {
                console.log("ERROR " + error);
                process.exit(0);
            }
        });
    });

    webSocket.on("message", function(message, flags) {
        //console.log("FRONTEND " + message);
        var length = Buffer.byteLength(message, "utf16le");
        var payload = new Buffer(length + 4);
        payload.writeInt32BE(length, 0);
        payload.write(message, 4, length, "utf16le");
        deviceSocket.write(payload);
    });

    deviceSocket.on("end", function() {
        console.info("Backend socket closed!");
        process.exit(0);
    });

    webSocket.on("close", function() {
        console.info('Frontend socket closed!');
        process.exit(0);
    });
});
