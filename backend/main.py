from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from downloder import YTD, InstagramDownloader
import asyncio
import os
import shutil
import zipfile
import tempfile

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


class YoutubeRequest(BaseModel):
    url: str
    quality: str = "highest"
    only_audio: bool = False


class InstagramRequest(BaseModel):
    url: str


@app.get("/")
async def read_root():
    return {"message": "Welcome to the Social Media Downloader API"}


@app.post("/youtube/video")
async def download_youtube_video(request: YoutubeRequest):
    try:
        file_path = await asyncio.to_thread(
            YTD.download_single_video,
            request.url,
            request.quality,
            request.only_audio,
        )
        filename = os.path.basename(file_path)
        return FileResponse(
            path=file_path,
            filename=filename,
            media_type="application/octet-stream",
            background=None, 
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/youtube/playlist")
async def download_youtube_playlist(request: YoutubeRequest):
    try:
        tmp_dir, paths = await asyncio.to_thread(
            YTD.download_playlist,
            request.url,
            request.quality,
            request.only_audio,
        )
       
        zip_path = os.path.join(tempfile.mkdtemp(), "playlist.zip")
        with zipfile.ZipFile(zip_path, "w") as zf:
            for p in paths:
                zf.write(p, arcname=os.path.basename(p))
        shutil.rmtree(tmp_dir, ignore_errors=True)

        return FileResponse(
            path=zip_path,
            filename="playlist.zip",
            media_type="application/zip",
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/instagram/post")
async def download_instagram_post(request: InstagramRequest):
    try:
        file_path = await asyncio.to_thread(
            InstagramDownloader.download_post,
            request.url,
        )
        filename = os.path.basename(file_path)
        return FileResponse(
            path=file_path,
            filename=filename,
            media_type="application/octet-stream",
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))