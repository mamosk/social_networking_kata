process.env.NODE_TLS_REJECT_UNAUTHORIZED = 0;
const options = {
    host: "localhost",
    port: process.env.PORT || 1881,
    path: "/",
    timeout: 3791
};
require("http")
    .get(options, res => {
        let s = res.statusCode;
        process.stdout.write(`${s}`);
        process.exit(s < 200 || s > 500);
    })
    .on("error", err => process.exit(1));
