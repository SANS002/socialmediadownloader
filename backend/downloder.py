from pytubefix import YouTube, Playlist
import instaloader
import os


class YTD:

    def download_single_video(url, quality="highest", only_audio=False):
        yt = YouTube(url)
        print(f"Title: {yt.title}")

        if only_audio:
            stream = yt.streams.filter(only_audio=True).first()
        else:
            if quality == "highest":
                stream = yt.streams.get_highest_resolution()
            else:
                stream = yt.streams.filter(res=quality, progressive=True).first()
        download_path = os.path.join(os.path.expanduser("~"), "Downloads")
        print("Downloading...")
        stream.download(download_path)
        print("Download complete")

    def download_playlist(url, quality="highest", only_audio=False):
        pl = Playlist(url)

        for video in pl.videos:
            yt = YouTube(video.watch_url)
            print(f"Downloading: {yt.title}")

            if only_audio:
                stream = yt.streams.filter(only_audio=True).first()
            else:
                if quality == "highest":
                    stream = yt.streams.get_highest_resolution()
                else:
                    stream = yt.streams.filter(res=quality, progressive=True).first()

            download_path = os.path.join(os.path.expanduser("~"), "Downloads")

            stream.download(download_path)

        print("Playlist download complete")

class InstagramDownloader:

    download_path = os.path.join(os.path.expanduser("~"), "Downloads")

    L = instaloader.Instaloader(
        download_comments=False,
        save_metadata=False,
        post_metadata_txt_pattern=""
    )

    def download_post(url, path=download_path):
        try:
            os.chdir(path)

            shortcode = url.split("/")[-2]
            post = instaloader.Post.from_shortcode(InstagramDownloader.L.context, shortcode)

            InstagramDownloader.L.download_post(post, target=shortcode)

            print("Only media downloaded in:", path)

        except Exception as e:
            print("Error:", e)