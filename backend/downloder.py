from pytubefix import YouTube, Playlist
from pytubefix.cli import on_progress
import instaloader
import os
import tempfile
import time
import random

class YTD:

    @staticmethod
    def _build_yt(url):
        return YouTube(
            url,
            use_oauth=True,
            allow_oauth_cache=True,
            client='WEB',
            on_progress_callback=on_progress
        )

    @staticmethod
    def download_single_video(url, quality="highest", only_audio=False):
        yt = YTD._build_yt(url)
        tmp_dir = tempfile.mkdtemp()

        if only_audio:
            stream = yt.streams.filter(only_audio=True).first()
        elif quality == "highest":
            stream = yt.streams.get_highest_resolution()
        else:
            stream = yt.streams.filter(res=quality, progressive=True).first()

        if stream is None:
            raise ValueError(f"No stream found for quality: {quality}")

        return stream.download(output_path=tmp_dir)

    @staticmethod
    def download_playlist(url, quality="highest", only_audio=False):
        pl = Playlist(url)
        tmp_dir = tempfile.mkdtemp()
        paths = []

        for video in pl.videos:
            try:
                yt = YTD._build_yt(video.watch_url)

                if only_audio:
                    stream = yt.streams.filter(only_audio=True).first()
                elif quality == "highest":
                    stream = yt.streams.get_highest_resolution()
                else:
                    stream = yt.streams.filter(res=quality, progressive=True).first()

                if stream:
                    out_path = stream.download(output_path=tmp_dir)
                    paths.append(out_path)

            except Exception as e:
                print(f"Skipping {video.watch_url}: {e}")

            time.sleep(random.uniform(1.5, 4.0))

        if not paths:
            raise ValueError("No videos were downloaded from playlist")

        return tmp_dir, paths


class InstagramDownloader:

    L = instaloader.Instaloader(
        download_comments=False,
        save_metadata=False,
        post_metadata_txt_pattern=""
    )

    @staticmethod
    def _extract_shortcode(url):
        url = url.rstrip("/")
        parts = url.split("/")
        for i, part in enumerate(parts):
            if part in ("p", "reel", "tv") and i + 1 < len(parts):
                return parts[i + 1]
        raise ValueError(f"Could not extract shortcode from URL: {url}")

    @staticmethod
    def download_post(url):
        tmp_dir = tempfile.mkdtemp()

        shortcode = InstagramDownloader._extract_shortcode(url)
        post = instaloader.Post.from_shortcode(InstagramDownloader.L.context, shortcode)
        InstagramDownloader.L.download_post(post, target=tmp_dir)

        allowed_ext = (".mp4", ".jpg", ".jpeg", ".png", ".webp")
        files = [
            f for f in os.listdir(tmp_dir)
            if f.lower().endswith(allowed_ext)
        ]

        if not files:
            raise FileNotFoundError("No media files found after download")

        return os.path.join(tmp_dir, files[0])