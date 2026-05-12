from fastapi import FastAPI, HTTPException, BackgroundTasks
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

def cleanup(*paths: str):
    for path in paths:
        try:
            if os.path.isdir(path):
                shutil.rmtree(path, ignore_errors=True)
            elif os.path.isfile(path):
                os.remove(path)
        except Exception:
            pass

@app.get("/")
async def read_root():
    return {"message": "Welcome to the Social Media Downloader API"}

@app.post("/youtube/video")
async def download_youtube_video(request: YoutubeRequest, background_tasks: BackgroundTasks):
    try:
        file_path = await asyncio.to_thread(
            YTD.download_single_video,
            request.url,
            request.quality,
            request.only_audio,
        )
        tmp_dir = os.path.dirname(file_path)
        filename = os.path.basename(file_path)
        background_tasks.add_task(cleanup, tmp_dir)
        return FileResponse(
            path=file_path,
            filename=filename,
            media_type="application/octet-stream",
            background=background_tasks,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/youtube/playlist")
async def download_youtube_playlist(request: YoutubeRequest, background_tasks: BackgroundTasks):
    try:
        tmp_dir, paths = await asyncio.to_thread(
            YTD.download_playlist,
            request.url,
            request.quality,
            request.only_audio,
        )
        zip_dir = tempfile.mkdtemp()
        zip_path = os.path.join(zip_dir, "playlist.zip")
        with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
            for p in paths:
                zf.write(p, arcname=os.path.basename(p))
        background_tasks.add_task(cleanup, tmp_dir, zip_dir)
        return FileResponse(
            path=zip_path,
            filename="playlist.zip",
            media_type="application/zip",
            background=background_tasks,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/instagram/post")
async def download_instagram_post(request: InstagramRequest, background_tasks: BackgroundTasks):
    try:
        file_path = await asyncio.to_thread(
            InstagramDownloader.download_post,
            request.url,
        )
        tmp_dir = os.path.dirname(file_path)
        filename = os.path.basename(file_path)
        background_tasks.add_task(cleanup, tmp_dir)
        return FileResponse(
            path=file_path,
            filename=filename,
            media_type="application/octet-stream",
            background=background_tasks,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))