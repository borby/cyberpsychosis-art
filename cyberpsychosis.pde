PImage base;
float flicker = 0;
JSONArray diaryEntries;
float increment = 0.02;
float zoff = 0.0;  
float zincrement = 0.02; 
int frameCount = 0;

void settings() {
    diaryEntries = loadJSONArray("assets/diary.json");
    base = loadImage("assets/cyber.png");
    size(int(base.width/2), int(base.height/2));
}

void setup() {
    PFont consoleFont = createFont("Workbench", 28);
    textFont(consoleFont);
}

// params follow similar structure as text() method
// px is font pixel size
void drawCRTText(String msg, float x, float y, float x1, float y2, int px) {
    // Outer text glow (blur simulation via opacity)
    fill(0, 209, 255, 30 * flicker);
    textSize(px + 4);
    text(msg, x, y, x1, y2);
    
    // Inner bright core text
    fill(173, 240, 255, 220 * flicker);
    textSize(px);
    text(msg, x, y, x1, y2);
}

// Many parts of code from https://processing.org/examples/noise3d.html, author Daniel Shiffman
void drawNoise() {
    loadPixels();

    float xoff = 0.0; // Start xoff at 0
    float clamp = 200.0;

    // For every x,y coordinate in a 2D space, calculate a noise value and produce a brightness value
    for (int x = 0; x < width; x++) {
        xoff += increment;   // Increment xoff 
        float yoff = 0.0;   // For every xoff, start yoff at 0
        for (int y = 0; y < height; y++) {
            yoff += increment; // Increment yoff
            
            // Calculate noise and scale by 255
            float bright = noise(xoff,yoff,zoff) * 255;

            // Combine noise values with current pixel colour to shift brightness via rgb value 
            int loc = x + y * width;
            color c = pixels[loc];
            float r = red(c) + bright - clamp;
            float g = green(c) + bright - clamp;
            float b = blue(c) + bright - clamp;
            
            pixels[loc] = color(r, g, b);
        }
    }
    updatePixels();

    zoff += zincrement; // Increment zoff
}

void drawVignette() {
    loadPixels();
    float maxDist = dist(0, 0, width/2, height/2);

    for (int x = 0; x < width; x++) {
        for (int y = 0; y < height; y++) {
            int loc = x + y * width;
            float d = dist(width/2, height/2, x, y);
            float factor = map(d, 0, maxDist, 0, 1);
            factor = pow(factor, 2); // Adjust curve of the falloff

            // Multiply current pixel color by vignette factor
            color c = pixels[loc];
            float r = red(c) * (1 - factor);
            float g = green(c) * (1 - factor);
            float b = blue(c) * (1 - factor);
            
            pixels[loc] = color(r, g, b);
        }
    }
    updatePixels();
}

// Draws semi-transparent horizontal black lines
void drawScanlines(int weight, int spacing) {
    stroke(0, 0, 0, 90);
    strokeWeight(weight);
    for (int y = 0; y < height; y += spacing) {
        line(0, y, width, y);
    }
}

void draw() {
    background(11, 18, 23);
    String debug_entry = diaryEntries.getJSONObject(0).getString("essence");
    drawCRTText(debug_entry, 0, 0, width, height, 28);
    flicker = random(0.85, 1.0);
    drawNoise();
    drawScanlines(8, 12);
    image(base, 0, 0, width, height);
    drawVignette();

    // debug export frames for ffmpeg stich
    saveFrame("output/frame-####.png"); 
    frameCount++;

    // Optional: Stop the sketch after a specific number of frames
    if (frameCount == 120) { 
        noLoop();
    }
}

