function setHeader(req, res, closeCallback) {
  res.writeHead(200, {
    "Content-Type": "text/event-stream",
    "Cache-Control": "no-cache",
    "Connection": "keep-alive"
  });
  res.flushHeaders();

  req.on('close', () => {
    res.end();
    if(closeCallback && typeof closeCallback == "function") closeCallback();
  })
}

function writeResponse(res, data) {
  res.write(`data: ${JSON.stringify(data)}\n\n`);
}

export { setHeader, writeResponse };
