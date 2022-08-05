'********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

sub Main()
    showChannelSGScreen()
  end sub
  
  sub showChannelSGScreen()
    m.playing = false
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)
    scene = screen.CreateScene("VideoExample")
    screen.show()
    m.titles = CreateObject("roList")
    m.uris = CreateObject("roList")
    m.sc = scene
    m.remlat = CreateObject("roList")
    'queryScreen(scene, "Terminator")
    scene.observeField("okPressed", m.port)
    keyboarddialog = m.sc.findNode("kb")
    keyboarddialog.backgroundUri = "pkg:/images/rsgde_dlg_bg_hd.9.png"
    keyboarddialog.title = "Search Dialog"
    keyboarddialog.buttons=["Ok","Cancel"]
    keyboarddialog.optionsDialog=true
    REM keyboarddialog.visible=true
    REM keyboarddialog.setFocus(true)
    keyboarddialog.observeField("buttonSelected",m.port)
    'playVideo(scene, "4040")
    while(true)
      msg = wait(0, m.port)
      msgType = type(msg)
      kb = scene.findNode("kb")
      logEvent (msg)
      if m.playing = false then
        if kb.buttonSelected = 0 then
            kb.visible=false
            kb.close=true
            scene.findNode("ttl").visible=false
            scene.findNode("searchBtn").visible=false
            kb.setFocus(false)
            txt = kb.text
            scene.setFocus(true)
            scene.removeChild(kb)
            queryScreen(scene, txt)
        end if
        if kb.buttonSelected = 1 then
            kb.visible = false  
            kb.close = true
            kb.setFocus(false)
            scene.findNode("searchBtn").setFocus(true)
        end if
      end if
      if scene.okPressed then
        posit = scene.selection
        title = m.titles[posit]
        href = m.uris[posit]
        i = 4
        id = CreateObject("roString")
        while id.Instr("-") = -1
            id = href.Right(i)
            i++
        end while
        id = id.Right(id.Len() - 1)
        id = id.Left(id.Len() - 5)
        playVideo(scene, id, title)
        scene.okPressed = false
      end if
      if msgType = "roSGScreenEvent"
        if msg.isScreenClosed() then return
      end if
    end while
  
  end sub
Function playVideo(scene, id, title) as void
  m.playing = true
  scene.removeChildren(m.remlat)
  scene.curScr = "video"
  str = ""
  link = CreateObject("roUrlTransfer")
  link.setUrl("https://ww5.0123movie.net/movie_embed.html")
  roPort = CreateObject("roMessagePort")
  link.setPort(roPort)
  link.SetCertificatesFile("common:/certs/ca-bundle.crt")
  link.InitClientCertificates()
  REM ta=ReadAsciiFile("tmp:/data.txt")
  if (link.AsyncPostFromString("pmid=" + id + "&peid=1&psrv=1")) then
    roEvent = wait(1500, link.GetPort())
    newLabel = createObject("RoSGNode", "Label")
    src = ParseJson(roEvent.GetString()).src
    str = right(src, src.Len() - "https://vidcloud9.org/watch?v=".Len())

  end if
  xml = CreateObject("roXMLElement")
  xml_str = CreateObject("roString")
  xml_str = GetXML("https://vidcloud9.org/watch?v=" + str)
  xml_str = xml_str.Right(xml_str.Len() - xml_str.Instr("xhr.setRequestHeader('x-csrf-token',") - 2 - "xhr.setRequestHeader('x-csrf-token',".Len())
  xml_str = xml_str.Left(xml_str.Instr("'"))
  data = CreateObject("roUrlTransfer")
  data.setUrl("https://vidcloud9.org/data")
  data.AddHeader("x-csrf-token", xml_str)
  data.AddHeader("Content-Type", "application/json")
  data.setPort(roPort)
  data.SetCertificatesFile("common:/certs/ca-bundle.crt")
  data.InitClientCertificates()
  REM ta=ReadAsciiFile("tmp:/data.txt")
  if (data.AsyncPostFromString("{""doc"":""" + str + """}")) then
    roEvent = wait(1500, link.GetPort())
    newLabel = createObject("RoSGNode", "Label")
    res = roEvent.GetString()
    ? "code: "; roEvent.GetResponseCode()
    src = ParseJson(roEvent).url
    ba = CreateObject("roByteArray")
    ba.FromBase64String(src)
    str = "https://vidcloud9.org" + ba.ToAsciiString()

  end if
  master = CreateObject("roUrlTransfer")
  master.setUrl(str)
  master.SetCertificatesFile("common:/certs/ca-bundle.crt")
  master.InitClientCertificates()
  src = master.GetToString()
  str = "https://vidcloud9.org" + Right(src, src.Len() - src.Instr("/"))
  videocontent = createObject("RoSGNode", "ContentNode")

  videocontent.title = title
  REM videocontent.streamformat = "m3u8"
  videocontent.url = str
  REM videocontent.switchingstrategy = "full-adaptation"
  REM videocontent.live = true

  video = createObject("RoSGNode", "Video")
  scene.appendChild(video)
  video.setFocus(true)
  video.content = videocontent
  video.control = "play"
  video.enableTrickPlay = true
end function
Function queryScreen(scene, query) as void
scene.findNode("outline").visible = "true"
scene.curScr = "query"
xml = CreateObject("roXMLElement")
xml_str = CreateObject("roString")
xml_str = GetXML("https://ww5.0123movie.net/search/" + query.EncodeUri() + ".html")
result = xml.Parse(xml_str)
'movieTable = xml.GetChildElements()[1].GetChildElements()[1].GetChildElements()[0].GetChildElements()[2].GetChildElements()[0].GetChildElements()
m.mTable = xml.GetChildElements()[1].GetChildElements()[1].GetChildElements()[0].GetChildElements()[2].GetChildElements()[0].GetChildElements()
xOff = 32
yOff = 32
'grid = CreateObject("RoSGNode", "PosterGrid")
'm.readPosterGridTask = createObject("roSGNode", "ContentNode")
'm.readPosterGridTask.contenturi = "http://www.sdktestinglab.com/Tutorial/content/rendergridps.xml"
'sleep(1000)
REM m.readPosterGridTask.observeField("content", "showpostergrid")
REM m.readPosterGridTask.control = "RUN"
'grid.content = m.readPosterGridTask.content
'scene.appendChild(grid)
count = m.mTable.Count()
for i=1 to m.mTable.Count()
  newLabel = createObject("RoSGNode", "Label")
  newPoster = createObject("RoSGNode", "Poster")
  gradient = createObject("RoSGNode", "Poster")
  gradient.id="thumb"
  gradient.uri = "pkg:/images/gradient.png"
  newPoster.uri = m.mTable[i - 1].GetChildElements()[0].GetChildElements()[0]@src
  newLabel.text=m.mTable[i - 1].GetChildElements()[0]@title
  m.uris.Push(m.mTable[i - 1].GetChildElements()[0]@href)
  m.titles.Push(m.mTable[i - 1].GetChildElements()[0]@title)
  REM newLabel.text = newPoster.bitmapWidth.toStr()
  newLabel.horizAlign = "center"
  newLabel.vertAlign = "center"
  newPoster.translation = [xOff,yOff]
  gradient.translation = [0, 184]
  gradient.width = 176
  gradient.height = 80
  xOff = xOff + 208
  newLabel.wrap = true
  if newPoster.uri.Instr("data:image/svg+xml") = -1 then
    scene.appendChild(newPoster)
    newPoster.width = 176
    newPoster.id="thumb"
    newPoster.height = 264
    newLabel.width = 176
    newLabel.id="thumb"
    newLabel.height = 80
    newPoster.appendChild(gradient)
    gradient.appendChild(newLabel)
    m.remlat.Push(newPoster)
    'm.remlat.Push(gradient)
    'm.remlat.Push(newLabel)
  end if
  REM newLabel.translation = [0, newLabel.height / 2]
  if i MOD 6 = 0 then
    yOff += 294
    xOff = 32
  end if
end for
end function
Function GetXML(url as String) as string
	link = CreateObject("roUrlTransfer")
	link.setUrl(url)
	link.SetCertificatesFile("common:/certs/ca-bundle.crt")
	link.InitClientCertificates()
	
	return link.GetToString()
end function
Function timeNow () As String
    dt = CreateObject ("roDateTime")
    dt.ToLocalTime ()
    hh = Right ("0" + dt.GetHours ().ToStr (), 2)
    mm = Right ("0" + dt.GetMinutes ().ToStr (), 2)
    ss = Right ("0" + dt.GetSeconds ().ToStr (), 2)
    mmm = Right ("00" + dt.GetMilliseconds ().ToStr (), 3)
    Return hh + ":" + mm + ":" + ss + "." + mmm
End Function
Function logEvent (msg As Object) As Void
    message = ""
    index = 0
    info = Invalid
    If msg = Invalid
        Print timeNow (); "  Timeout"
    Else
        msgType = Type (msg)
        If msgType = "roVideoScreenEvent" Or msgType = "roVideoPlayerEvent"
            If msg.IsStreamStarted()
                evType = "IsStreamStarted"
                index = msg.GetIndex()
                info = msg.GetInfo()
            Else If msg.IsPlaybackPosition()
                evType = "IsPlaybackPosition"
                index = msg.GetIndex()
            Else If msg.IsRequestFailed()
                evType = "IsRequestFailed"
                message = msg.GetMessage()
                index = msg.GetIndex()
                info = msg.GetInfo()
            Else If msg.IsStatusMessage()
                evType = "IsStatusMessage"
                message = msg.GetMessage()
            Else If msg.IsFullResult()
                evType = "IsFullResult"
            Else If msg.IsPartialResult()
                evType = "IsPartialResult"
            Else If msg.IsPaused()
                evType = "IsPaused"
            Else If msg.IsResumed()
                evType = "IsResumed"
            Else If msg.IsScreenClosed()
                evType = "IsScreenClosed"
            Else If msg.IsStreamSegmentInfo()
                evType = "IsStreamSegmentInfo"
                message = msg.GetMessage ()
                index = msg.GetIndex()
                info = msg.GetInfo()
            Else If msg.IsDownloadSegmentInfo()    ' Undocumented event
                evType = "IsDownloadSegmentInfo"
                message = msg.GetMessage()
                index = msg.GetIndex()
                info = msg.GetInfo()
            Else If msg.IsListItemSelected()       ' Undocumented event
                evType = "IsListItemSelected"
                index = msg.GetIndex()
            Else
                evType = "Unknown"
            EndIf
            timeNowStr = timeNow()
            tabs = Len (timeNowStr) + Len (msgType) + 4
            Print timeNowStr; "  "; msgType; ". Event Type: "; evType + " [" + msg.GetType ().ToStr () + "]. "; "Index: " + index.ToStr ();
            If message <> ""
                Print ". Message: "; message
            Else
                Print ""
            EndIf
            If Type (info) = "roAssociativeArray"
                For Each key In info
                    infoKey = info [key]
                    If Type (GetInterface (infoKey, "ifIntOps")) = "ifIntOps"
                        Print Tab (tabs); key + ": " + infoKey.ToStr ()
                    Else
                        Print Tab (tabs); key + ": "; infoKey
                    EndIf
                End For
            EndIf
        Else
            ' An event type other than "roVideoScreenEvent" or "roVideoPlayerEvent"
            ' Add additional code here to handle other event types
            print msgType; ". Event Type: [" + "" + "]"
        Endif
    EndIf
End Function