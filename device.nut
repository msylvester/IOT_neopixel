#require "WS2812.class.nut:1.0.1"
 

const NUMPIXELS = 16;
const DELAY = 0.02;
const SPICLK = 7500; // kHz
const COLORDELTA = 8;
 

spi <- hardware.spi257;
spi.configure(MSB_FIRST, SPICLK);
pixelStrip <- WS2812(spi, NUMPIXELS);


redVal <- 0;
greenVal <- 0;
blueVal <- 0;
redDel <- 1;
greenDel <- 1;
blueDel <- 1;
redOn <- true;
greenOn <- false;
blueOn <- false;
 
timer <- null;
pixel <- 0;
pDelta <- 1;
 
function glowinit(dummy) {
  
    if (timer != null) imp.cancelwakeup(timer);

    redVal = 0;
    greenVal = 0;
    blueVal = 0;

    redDel = COLORDELTA;
    greenDel = COLORDELTA;
    blueDel = COLORDELTA;
 
    redOn = true;
    greenOn = false;
    blueOn = false;

    glow();
}
 
function glow() {
    for (local i = 0 ; i < NUMPIXELS ; i++) pixelStrip.writePixel(i, [redVal, greenVal, blueVal]);
    pixelStrip.writeFrame();
    adjustColors();
    timer = imp.wakeup(DELAY, glow);
}
 
function randominit(dummy) {
    // A random pixel glows a random color
    if (timer != null) imp.cancelwakeup(timer);
    random();
}
 
function random() {
    pixelStrip.clearFrame();
    pixelStrip.writeFrame();

    redVal = ran(255);
    greenVal = ran(255);
    blueVal = ran(255);
    pixel = ran(NUMPIXELS);

    pixelStrip.writePixel(pixel, [redVal, greenVal, blueVal]);
    pixelStrip.writeFrame();

    timer = imp.wakeup(DELAY * 2, random);
}
 
function looperinit(dummy) {
  
    if (timer != null) imp.cancelwakeup(timer);

    redVal = 0;
    greenVal = 0;
    blueVal = 0;
 
    redDel = COLORDELTA;
    greenDel = COLORDELTA;
    blueDel = COLORDELTA;
 
    redOn = true;
    greenOn = false;
    blueOn = false;

    pixel = 0;
    pDelta = 1;

    looper();
}
 
function looper() {
    pixelStrip.clearFrame();
    pixelStrip.writePixel(pixel, [redVal, greenVal, blueVal]);
    pixelStrip.writeFrame();

    pixel++;
    if (pixel > 15) pixel = 0;

    adjustColors();
    timer = imp.wakeup(DELAY, looper);
}
 
function larsoninit(dummy) {
    if (timer != null) imp.cancelwakeup(timer);

    redVal = 0;
    greenVal = 0;
    blueVal = 0;

    redDel = COLORDELTA;
    greenDel = COLORDELTA;
    blueDel = COLORDELTA;

    redOn = true;
    greenOn = false;
    blueOn = false;

    pixel = 0;
    pDelta = 1;

    larson();
}
 
function larson() {
    pixelStrip.clearFrame();
    pixelStrip.writeFrame();
    
    pixel = pixel + pDelta;
    if (pixel > 7) {
        pDelta = -1;
        pixel = 6;
    }

    if (pixel < 0) {
        pDelta = 1;
        pixel = 1;
    }

    if (redOn) {
        redVal = redVal + redDel;
        if (redVal > 127) {
            redDel = COLORDELTA * -1;
            greenOn = true;
        }

        if (redVal < 1) {
            redDel = COLORDELTA;
            redOn = false;
        }
    }

    if (greenOn) {
        greenVal = greenVal + greenDel;
        if (greenVal > 127) {
            greenDel = COLORDELTA * -1;
            blueOn = true;
        }

        if (greenVal < 1) {
            greenDel = COLORDELTA;
            greenOn = false;
        }
    }

    if (blueOn) {
        blueVal = blueVal + blueDel;
        if (blueVal > 127) {
            blueDel = COLORDELTA * -1;
            redOn = true;
        }

        if (blueVal < 1) {
            blueDel = COLORDELTA;
            blueOn = false;
        }
    }
 
    server.log(format("%i %i %i", redVal, greenVal, blueVal));
    pixelStrip.writePixel(pixel, [redVal, greenVal, blueVal]);
    pixelStrip.writePixel(15 - pixel, [redVal, greenVal, blueVal]);
    pixelStrip.writeFrame();

    timer = imp.wakeup(DELAY, larson);
}
 
function ran(max) {
    // Generate a pseudorandom number between 0 and (max - 1)
    local roll = 1.0 * math.rand() / RAND_MAX;
    roll = roll * max;
    return roll.tointeger();
}
 
function adjustColors() {
    if (redOn) {
        redVal = redVal + redDel;
        if (redVal > 254) {
            redVal = 256 - COLORDELTA;
            redDel = COLORDELTA * -1;
            greenOn = true;
        }

        if (redVal < 1) {
            redDel = COLORDELTA;
            redOn = false;
            redVal = 0;
        }
    }

    if (greenOn) {
        greenVal = greenVal + greenDel;
        if (greenVal > 254) {
            greenDel = COLORDELTA * -1;
            blueOn = true;
            greenVal = 256 - COLORDELTA;
        }

        if (greenVal < 1) {
            greenDel = COLORDELTA;
            greenOn = false;
            greenVal = 0;
        }
    }

    if (blueOn) {
        blueVal = blueVal + blueDel;
        if (blueVal > 254) {
            blueDel = COLORDELTA * -1;
            redOn = true;
            blueVal = 256 - COLORDELTA;
        }

        if (blueVal < 1) {
            blueDel = COLORDELTA;
            blueOn = false;
            blueVal = 0;
        }
    }
}
 
function setColor(color) {
    if (timer!= null) imp.cancelwakeup(timer);
    pixelStrip.clearFrame();
    pixelStrip.writeFrame();
    local colors = split(color, ".");
    local red = colors[0].tointeger();
    if (red < 0) red = 0;
    if (red > 255) red = 255;
    local green = colors[1].tointeger();
    if (green < 0) green = 0;
    if (green > 255) green = 255;
    local blue = colors[2].tointeger();
    if (blue < 0) blue = 0;
    if (blue > 255) blue = 255;
    for (local i = 0 ; i < NUMPIXELS ; i++) pixelStrip.writePixel(i, [red, green, blue]);
    pixelStrip.writeFrame();
}

agent.on("glow", glowinit);
agent.on("looper", looperinit);
agent.on("larson", larsoninit);
agent.on("random", randominit);
agent.on("setcolor", setColor);
 

switch (ran(4)) {
    case 0:
        glowinit(true);
        break;
    
    case 1:
        randominit(true);
        break;
        
    case 2:
        looperinit(true);
        break;
        
    case 3:
        larsoninit(true);
}