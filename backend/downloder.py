from pytubefix import YouTube, Playlist
import instaloader
import os
import tempfile
import shutil

class YTD:

    @staticmethod
    def download_single_video(url, quality="highest", only_audio=False):
        yt = YouTube(url)
        tmp_dir = tempfile.mkdtemp()  

        if only_audio:
            stream = yt.streams.filter(only_audio=True).first()
        else:
            if quality == "highest":
                stream = yt.streams.get_highest_resolution()
            else:
                stream = yt.streams.filter(res=quality, progressive=True).first()

        if stream is None:
            raise ValueError(f"No stream found for quality: {quality}")

        out_path = stream.download(output_path=tmp_dir)
        return out_path  

    @staticmethod
    def download_playlist(url, quality="highest", only_audio=False):
        pl = Playlist(url)
        tmp_dir = tempfile.mkdtemp()
        paths = []

        for video in pl.videos:
            yt = YouTube(video.watch_url)

            if only_audio:
                stream = yt.streams.filter(only_audio=True).first()
            else:
                if quality == "highest":
                    stream = yt.streams.get_highest_resolution()
                else:
                    stream = yt.streams.filter(res=quality, progressive=True).first()

            if stream:
                out_path = stream.download(output_path=tmp_dir)
                paths.append(out_path)

        return tmp_dir, paths  

class InstagramDownloader:

    L = instaloader.Instaloader(
        download_comments=False,
        save_metadata=False,
        post_metadata_txt_pattern=""
    )

    @staticmethod
    def download_post(url):
        tmp_dir = tempfile.mkdtemp()
        shortcode = url.rstrip("/").split("/")[-1] 
        post = instaloader.Post.from_shortcode(InstagramDownloader.L.context, shortcode)
        InstagramDownloader.L.download_post(post, target=tmp_dir)
        files = [f for f in os.listdir(tmp_dir) if not f.endswith(".txt")]
        if not files:
            raise FileNotFoundError("No media downloaded")
        return os.path.join(tmp_dir, files[0])