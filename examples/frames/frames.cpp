// Counts frames and shows the count, along with the refresh rate the GPU
// was configured for. Chapter 3, "Boot and the frame".

#include "ci.hh"
#include "psyqo/application.hh"
#include "psyqo/font.hh"
#include "psyqo/gpu.hh"
#include "psyqo/scene.hh"

namespace {

class Frames final : public psyqo::Application {
    void prepare() override;
    void createScene() override;

  public:
    psyqo::Font<> m_font;
};

class FramesScene final : public psyqo::Scene {
    void frame() override;
};

Frames frames;
FramesScene framesScene;

}  // namespace

void Frames::prepare() {
    psyqo::GPU::Configuration config;
    config.set(psyqo::GPU::Resolution::W320)
        .set(psyqo::GPU::VideoMode::AUTO)
        .set(psyqo::GPU::ColorMode::C15BITS)
        .set(psyqo::GPU::Interlace::PROGRESSIVE);
    gpu().initialize(config);
}

void Frames::createScene() {
    m_font.uploadSystemFont(gpu());
    pushScene(&framesScene);
}

void FramesScene::frame() {
    auto& gpu = frames.gpu();
    uint32_t count = gpu.getFrameCount();
    unsigned rate = gpu.getRefreshRate();

    gpu.clear({{.r = 0, .g = 0, .b = 0x30}});
    frames.m_font.printf(gpu, {{.x = 16, .y = 32}}, {{.r = 0xff, .g = 0xff, .b = 0xff}}, "frame %u", count);
    frames.m_font.printf(gpu, {{.x = 16, .y = 48}}, {{.r = 0xff, .g = 0xff, .b = 0xff}}, "%u Hz, %u.%02u s", rate,
                         count / rate, (count % rate) * 100 / rate);

    // Two seconds of frames is enough to show the vblank is ticking.
    if (count >= 2 * rate) BOOK_CI_PASS("frames count=%u rate=%u", count, rate);
}

int main() { return frames.run(); }
