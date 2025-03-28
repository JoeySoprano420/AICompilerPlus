#include <Windows.h>
#include <gdiplus.h>
#include <iostream>

using namespace Gdiplus;
#pragma comment(lib, "gdiplus.lib")

void CreateElaborateVACUImage(const wchar_t* filename) {
    // Initialize GDI+.
    GdiplusStartupInput gdiplusStartupInput;
    ULONG_PTR gdiplusToken;
    GdiplusStartup(&gdiplusToken, &gdiplusStartupInput, nullptr);

    // Create a Bitmap object to hold the image.
    int width = 512;
    int height = 512;
    Bitmap* bitmap = new Bitmap(width, height, PixelFormat32bppARGB);

    // Create a Graphics object to draw on the Bitmap.
    Graphics* graphics = Graphics::FromImage(bitmap);

    // Set anti-aliasing for smoother graphics.
    graphics->SetSmoothingMode(SmoothingModeAntiAlias);
    graphics->SetInterpolationMode(InterpolationModeHighQualityBicubic);

    // Draw Background with Gradient (Violet to Blue Aura)
    LinearGradientBrush backgroundBrush(Point(0, 0), Point(width, height),
                                        Color(255, 138, 43, 226), Color(255, 0, 0, 255));
    graphics->FillRectangle(&backgroundBrush, 0, 0, width, height);

    // Create radial gradient to simulate a glowing aura at the center.
    PathGradientBrush auraBrush(PointF(width / 2.0f, height / 2.0f));
    Color colors[] = { Color(255, 138, 43, 226), Color(255, 0, 0, 255), Color(255, 0, 255, 255) };
    auraBrush.SetInterpolationColors(colors, 3);
    graphics->FillEllipse(&auraBrush, width / 4, height / 4, width / 2, height / 2);

    // Add a cosmic starfield effect (small random white points) for extra depth.
    Random random;
    SolidBrush starBrush(Color(255, 255, 255));
    for (int i = 0; i < 500; ++i) {
        int x = random.Next(0, width);
        int y = random.Next(0, height);
        graphics->FillRectangle(&starBrush, x, y, 2, 2);
    }

    // Draw symbolic circular energy patterns.
    Pen pen(Color(255, 255, 255), 4);
    pen.SetDashStyle(DashStyleDot);
    graphics->DrawEllipse(&pen, width / 4.5, height / 4.5, width / 1.8, height / 1.8);
    graphics->DrawEllipse(&pen, width / 3, height / 3, width / 1.4, height / 1.4);
    graphics->DrawEllipse(&pen, width / 3.5, height / 3.5, width / 1.25, height / 1.25);

    // Add futuristic text ("VACU") in the center with a glowing effect.
    FontFamily fontFamily(L"Arial");
    Font font(&fontFamily, 48, FontStyleRegular, UnitPixel);
    SolidBrush textBrush(Color(255, 255, 255));
    PointF textPosition(width / 4.2f, height / 2.2f);
    graphics->DrawString(L"VACU", -1, &font, textPosition, &textBrush);

    // Create glow effect by adding more opaque white layers.
    SolidBrush glowBrush(Color(128, 138, 43, 226)); // Semi-transparent violet
    graphics->DrawString(L"VACU", -1, &font, textPosition, &glowBrush);

    // Draw a futuristic "V" symbol as part of the design.
    SolidBrush vBrush(Color(255, 255, 215)); // Golden color for the V symbol
    graphics->DrawString(L"V", -1, &font, PointF(width / 2.0f - 25, height / 1.5f), &vBrush);

    // Save the Bitmap to a file (as PNG for now, but can convert to .ico).
    CLSID pngClsid;
    GetEncoderClsid(L"image/png", &pngClsid);
    bitmap->Save(filename, &pngClsid);

    // Cleanup.
    delete graphics;
    delete bitmap;

    GdiplusShutdown(gdiplusToken);
}

// Function to get the CLSID of the encoder for a specific file format.
int GetEncoderClsid(const WCHAR* format, CLSID* pClsid) {
    UINT num = 0;
    UINT size = 0;
    ImageCodecInfo* pImageCodecInfo = NULL;

    GetImageEncodersSize(&num, &size);
    if (size == 0)
        return -1;

    pImageCodecInfo = (ImageCodecInfo*)(malloc(size));
    if (pImageCodecInfo == NULL)
        return -1;

    GetImageEncoders(num, size, pImageCodecInfo);

    for (UINT j = 0; j < num; ++j) {
        if (wcscmp(pImageCodecInfo[j].MimeType, format) == 0) {
            *pClsid = pImageCodecInfo[j].Clsid;
            free(pImageCodecInfo);
            return j;
        }
    }

    free(pImageCodecInfo);
    return -1;
}

int main() {
    const wchar_t* imagePath = L"ElaborateVACUImage.png";
    CreateElaborateVACUImage(imagePath);

    std::wcout << L"Elaborate image created at: " << imagePath << std::endl;

    return 0;
}
