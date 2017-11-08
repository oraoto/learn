#pragma comment(lib, "windowsapp")
#pragma comment(lib, "windowscodecs")

#include "winrt/Windows.Foundation.h"
#include "winrt/Windows.Media.Capture.h"
#include "winrt/Windows.Storage.h"
#include "winrt/Windows.Storage.Streams.h"
#include "winrt/Windows.Media.MediaProperties.h"
#include "winrt/Windows.Graphics.Imaging.h"
#include "winrt/Windows.Storage.FileProperties.h"
#include <thread>
#include <chrono>

using namespace winrt;
using namespace Windows::Foundation;
using namespace Windows::Media::Capture;
using namespace Windows::Storage;
using namespace Windows::Storage::Streams;
using namespace Windows::Media::MediaProperties;
using namespace Windows::Graphics::Imaging;
using namespace Windows::Storage::FileProperties;

IAsyncAction Capture()
{
    auto library = co_await StorageLibrary::GetLibraryAsync(KnownLibraryId::Pictures);
    auto save_folder = library.SaveFolder();
    auto folder = co_await save_folder.CreateFolderAsync(L"cppwinrt-capture", CreationCollisionOption::OpenIfExists);

    MediaCapture capture;
    co_await capture.InitializeAsync();

    auto props = ImageEncodingProperties::CreateJpeg();

    while (true) {
        auto file = co_await folder.CreateFileAsync(L"capture.jpg", CreationCollisionOption::GenerateUniqueName);
        co_await capture.CapturePhotoToStorageFileAsync(props, file);
        std::this_thread::sleep_for(std::chrono::seconds(30));
    }
}

int main()
{
    init_apartment();
    Capture().get();
}

// cl .\Capture.cpp /I.\cppwinrt\10.0.16299.0\ /std:c++latest /await /EHsc