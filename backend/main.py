from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from downloder import YTD,InstagramDownloader
from fastapi.middleware.cors import CORSMiddleware
import asyncio


app  = FastAPI()

origins = [

    "http://localhost",
]


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


class YoutubeRequest(BaseModel):
    url : str
    quality: str = "highest" 
    only_audio: bool = False

class PlayRequest(BaseModel):
    url : str
    quality: str = "highest" 
    only_audio: bool = False

class InstagramRequest(BaseModel):
    url : str


@app.get("/" )
async def read_root():
    return {"message": "Welcome to the Social Media Downloader API"}
@app.post("/youtube/video")
async def download_youtube_video(request: YoutubeRequest):
    try:
        await asyncio.to_thread(YTD.download_single_video(request.url, 
                                  request.quality, 
                                  request.only_audio))
        return {"message": "Video downloaded successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@app.post("/youtube/playlist")
async def download_youtube_playlist(request: PlayRequest):
    try:
        await asyncio.to_thread(YTD.download_playlist(request.url, 
                                                     request.quality, 
                                                     request.only_audio))
        return {"message": "Playlist downloaded successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@app.post("/instagram/post")
async def download_instagram_post(request: InstagramRequest):
    try:
        await asyncio.to_thread(InstagramDownloader.post_download(request.url))
        return {"status": "success", "folder": path}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
        
