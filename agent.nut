

function requestHandler(request, response) {
    try {
        if ("setcolor" in request.query) {
            device.send("setcolor", request.query.setcolor);
            response.send(200, "Color Set");
            return;
        }
        
        if ("glow" in request.query) {
            device.send("glow", true);
            response.send(200, "Glow effect on");
            return;
        }
        
        if ("random" in request.query) {
            device.send("random", true);
            response.send(200, "Random effect on");
            return;
        }
        
        if ("looper" in request.query) {
            device.send("looper", true);
            response.send(200, "Looper effect on");
            return;
        }
        
        if ("larson" in request.query) {
            device.send("larson", true);
            response.send(200, "Larson effect on");
            return;
        }
        
        response.send(200, "Waiting for a command");
    } catch (error) {
        server.log("Error: " + error);
    }
}
 

http.onrequest(requestHandler);