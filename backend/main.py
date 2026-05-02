from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from downloder import YTD,InstagramDownloader


app  = FastAPI()
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
def read_root():
    return {"message": "Welcome to the Social Media Downloader API"}
@app.post("/youtube/video")
def download_youtube_video(request: YoutubeRequest):
    try:
        YTD.download_single_video(request.url, 
                                  request.quality, 
                                  request.only_audio)
        return {"message": "Video downloaded successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@app.post("/youtube/playlist")
def download_youtube_playlist(request: PlayRequest):
    try:
        YTD.download_playlist(request.url, 
                             request.quality, 
                             request.only_audio)
        return {"message": "Playlist downloaded successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@app.post("/instagram/post")
def dowload_instagram_post(request: InstagramRequest):
    try:
        InstagramDownloader.post_download(request.url)
        
        return {"status": "success", "folder": path}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
        

