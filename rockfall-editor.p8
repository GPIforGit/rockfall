pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
--rockfall editor
--  by gpi

--[[
 < lshift+right prev cave
 > lshift+left next cave
 l change level
 tab parameter view
 0-9 ,.*/ select block
 - lshift+up prev line
 + lshift+down next line
 c sprite/boxmode
 return edit line
 shift+p set point: block,x,y
 p insert point
 shift+l set line: block,x1,y1,x2,y2
 l insert line
 shift+f set filled: rect block,block,x1,y1,x2,y2
 f insert fill
 shift+g set filled1: rect1 block,x1,y1,x2,y2
 g insert filled1
 shift+b set box: block,x1,y1,x2,y2
 b insert box
 shift+r set raster: block,x,y,w,h,dx,dy
 r insert raster
 shift+a set add: block,block,dx,dy
 a insert add
 shift+d delete line
 shift+s save
 shift+t test
 shift+z demo
 shift+u record demo
 shift+m switch between map-data-mode (needs more space) and list-data-mode (compact bd1&2-style)
 lmb set start
 rmb set end

 ctrl+c copy current cave (as text-string)
 ctrl+v overwrite current cave with clipboard
 ctrl+x cut cave
 ctrl+i insert cave
 ctrl+n new cave at the end

amoeba - geschwindigkeit start kontrollieren! - Boring?

--]]

editor=true

--base
#include rockfall-game.p8:0
--game
#include rockfall-game.p8:1
--cave
#include rockfall-game.p8:3

global[[
compareignoreheader={
name=true
intermission=true
loopx=true
loopy=true
needed=true
time=true
amoeba_time=true
amoeba_slow=true
amoeba_fast=true
amoeba_limit=true
magicwalltime=true
slime_permeability=true
map=true
demo=true
}
]]

if (dget(63)==0) global "reload(0,0,0x4300,rockfall-game.p8)"
-->8
--inextro

init_caveintro=prepare_cave


function update_caveintro() 
 if (phase==0) wait-=1
 if (wait < -3) change_gamemode "game"

 sprite_handle()
 cave_gamelogic()
end

function draw_caveintro()
 draw_cave()
end

function init_caveexit()
 setinfo("time:"..timer.." ◆:"..ply_gems)
 change_gamemode "editor"
end

-->8
--editor


function addpoke(...)
 if(_adr<0x3000)poke(_adr,...)
 _adr+=#{...}
end

function cave_len()
 return cave.ismap and mapheadersize or #header + #cave
end

function cave_str(l)
 if (l<0 or l>cave_len()) return "","",{}
 if (l<=#header) local h=header[l][1] return h,tstr(cave[h]),cave[h]
 l-=#header
 return cave[l][1],tstr(tsub(cave[l],2)),cave[l]
end

function cave_new()
 global[[
cave={
name=cave
size=40,22
intermission=false
needed=1,2,3,4,5
time=120,110,100,90,80
amoeba_time=60
amoeba_slow=8
amoeba_fast=64
amoeba_limit=200
magicwalltime=30
player=1,0,2,0
seed={}
slime_permeability=32
random=vOID,0,vOID,0,vOID,0,vOID,0
ismap=false
map={}
loopx=false
loopy=false
}
scx=nil
scy=nil
]]
 for i=1,5 do add(cave.seed,rnd(256)\1) end
end


function cave_write()
 
 local flag=cave_flag_valid
 for f,v in pairs(cave_flags) do
  if (cave[f]) flag|=v
 end
 addpoke(flag)
 
 for i=1,cave_len() do
  --local n,v,t,index
  if i<=#header then
   n=header[i]
   v=n[1]
   t,index=cave[v],2
  else
   v=i-#header
   n,t,index=lines[ cave[v][1] ],tsub(cave[v],2),3
   addpoke(n[1]*16+ block2id[block[t[1]]])
  end 

  local typ=type(n[index])  
  
  if typ=="string" then   
   addpoke(ord(t,1,#t-1))
   addpoke(ord(t,#t)|0x80)
   
  elseif typ=="boolean" then
   --addpoke(t and 1)
  else
   if (type(t)=="string") t=block[t]
   if (tonum(t)) t={t}
   for i=index,#n do
    local x=t[i-1]
    if (not tonum(x)) x=x and block[x] or n[i]
    addpoke(x)
   end    
  end
  
 end
 
 if cave.ismap then
  _adr-=0.5
  for c in all(cave.map) do
   write(c)
  end
  
  _adr=ceil(_adr)
 else
  addpoke(0)
 end
 
 for n in all(cave.demo) do
  addpoke(demomove[n[1]]+n[2]*demodiv)
 end
 addpoke(0)
 
end

function cave_copy()
 local str=""
 for i=1,cave.ismap and mapheadersize or #header do
  local h=header[i] 
  str..=h[1].."="..tstr(cave[h[1]]).."\n"
 end
 if cave.ismap then
  for y=0,gameh1 do
   for x=0,gamew1 do
    str..= block2ascii[mget(x,y)]
   end
   str..="\n"
  end
 else
  for e in all(cave) do
   str..=tstr(e).."\n"
  end

 end

 printh(str,"@clip")
 setinfo"copy cave"
end

function cave_paste()
 local t,b=table(stat(4) or "")
 for i,h in pairs(header) do
  if (t[h[1]]==nil) b=i break
 end

 if b==mapheadersize+1 then
  t.ismap,t.map=true,{}
  for li=2,#t-1 do
   local l=t[li]
   for c=2,#l-1 do
    add(t.map,block2id[ block2ascii[sub(l,c,c)] or 0])
   end
  end 
  while #t>0 do
   deli(t,1)
  end  
  
 elseif b then
  setinfo "illegal format" 
  return false
 end 
 caves[currentcave],cave=t,t 
 
 render()
 cave_compress()
 
end



function caves_store()
 
 global[[
memset(0x1000,0,@maxlevelsize)
_adr=0x1000
cs_oldcave=@cave
]]
 

 for c in all(caves) do
global[[
cave=c
cave_write()
]]
 end
 global[[
cstore(0x1000,0x1000,@maxlevelsize)
dset(63,1)
cave=@cs_oldcave
]]
 setinfo(_adr-0x1000 .." bytes ("..ceil((_adr-0x1000)/maxlevelsize*100)..")%")
end



function init_editorstart()
 global[[
zoom=5
camx=0
camy=0
cx=0
cy=0
showsprite=@TRUE
curline=1
currentcave=@startcave
level=1
poke(0x5f2d,0x1)
change_gamemode(editor)
]]
end

function exit_editor()
 global[[
poke2(0x5f5c,0)
]]
end

function init_editor()
 cave=caves[currentcave] 
 global[[
render()
esel=1
addline=0
oldcave=@currentcave
record=@FALSE
demo=@FALSE
oldcavedata={}
curblock=@block_void
oldismap=@FALSE
savemap=@FALSE
poke2(0x5f5c,0x010e)
pal(@colors.1,1)
clearkeys=true
eheader="pLEASE WAIT..."
eline=""
etable={}
]]
 
end

function comparecopy(t,oldt,dif)
 if (not oldt or #t != #oldt) oldt={}
 dif=dif or #t!=#oldt

 for k,v in pairs(t) do
  if not compareignoreheader[k] then
   if type(v)=="table" then
    dif,oldt[k]=comparecopy(v,oldt[k],dif)

   elseif v!=oldt[k] then
    oldt[k],dif=v,true
   end
  end
 end
 
 return dif,oldt
end

function render()
 cave_render()
 gems=0
 butterflys=0
 for x=1,gamew1 do
  for y=1,gameh1 do
   local t=mget(x,y)
   if (mget(x,y)==block_gem) gems+=1
   if (mget(x,y)==block_butterfly) butterflys+=1
  end
 end
end

function update_editor()
 key,wheel,mb,mx,my=stat(30) and stat(31),stat(36),stat(34),stat(32),stat(33)
 cx,cy=mx\zoom+camx,my\zoom+camy
 
 if key or mb!=0 then
  global[[
btnp⬇️=false
btnp⬆️=false
btnp⬅️=false
btnp➡️=false
  ]]
 else
  btnp⬇️,btnp⬆️,btnp⬅️,btnp➡️=btnp(⬇️),btnp(⬆️),btnp(⬅️),btnp(➡️)
  if (btnp(❎)) key="del"
  if (btnp(🅾️)) key="ins"
  if (btn(4,1)) key="shift"
 end
 
 if(btn(6)) poke(0x5f30,1) key=key or "\r"

 
 clearkeys= clearkeys and (btn()!=0 or key or mb!=0)
 if (clearkeys) return false
 
 if listview then
  if (btnp⬆️) curline-=1
  if (btnp⬇️) curline+=1
  if (key=="\9") listview=false
  if curline>=#header then
   if (key=="\200" and copyline) add(cave,tcpy(copyline),curline-#header)
   if (key=="\215") copyline=tcpy(cave[curline-#header]) deli(cave,curline-#header) 
   if (key=="\194") copyline=tcpy(cave[curline-#header])
   if (key=="\213") cave[curline-#header] = tcpy(copyline)
  end

  
 elseif not inputmode then 
  if (key=="+" or (key=="shift" and btnp⬇️)) curline+=1
  if (key=="-" or (key=="shift" and btnp⬆️)) curline-=1
  if (key==">" or (key=="shift" and btnp➡️)) currentcave+=1
  if (key=="<" or (key=="shift" and btnp⬅️)) currentcave-=1
  
  
  if (key=="\200") cave_new() add(caves,cave,currentcave) cave_paste()
  if (key=="\215") cave_copy() del(caves,cave) oldcave=nil
  
  if (key=="\205" or #caves<=0) cave_new() add(caves,cave) currentcave=#caves
  
  --if (key=="⬇️" and curline>#header) del(cave,etable) clearkeys=true
  if (key=="\213") cave_paste()
  if (key=="\194") cave_copy()
  if (key=="d") level=level%5+1
  if (key=="c") showsprite=not showsprite
  if (key=="\9") listview,epos,listy=true,#eline+1,0
  
  if (key=="★") cave_compress() caves_store() cstore() oldcave=currentcave
  if (key=="⧗") change_gamemode "gamestart" return false
  if (key=="⬆️") record=true change_gamemode "gamestart" return false
  if (key=="▥") demo=true change_gamemode "gamestart" return false

  if (key=="\r" and eheader!="" ) inputmode,epos,key=true,#eline+1

  if curline>=#header then
   if (defline[key]) cave[curline-#header]=tcpy(defline[key]) inputmode,key,overwriteeline=true,"\r",eline
   if (defnewline[key]) curline=min(curline+1,cave_len()+1) add(cave,tcpy(defnewline[key]),curline-#header)
   if (key=="ins") add(cave,tcpy(defline["⬅️"]),curline-#header) cleareline=true
   if (key=="del") del(cave,etable) oldline=nil
  end  

  if key=="😐" then    
   if cave.ismap then 
    cave_new()
    caves[currentcave]=cave
   else
    cave_compress()   
   end
   cave.ismap=not cave.ismap
  end
  
  
  if (key=="shift" and wheel>0) zoom+=1
  if (key=="shift" and wheel<0) zoom-=1  
  zoom=mid(2,8,zoom)
  
  if not key then
   if (btnp⬅️) camx-=1
   if (btnp➡️) camx+=1
   if (btnp⬆️) camy-=1
   if (btnp⬇️) camy+=1    
  end
  if (key=="shift" and mb==1) or mb==4 then
   if (scx)camx+=scx-mx\zoom 
   if (scy)camy+=scy-my\zoom
   scx,scy=mx\zoom,my\zoom
  else
   scx,scy=nil
  end
  
  camx=mid(camx,0,max(0,gamewidth-128\zoom))
  camy=mid(camy,0,max(0,gameheight-114\zoom)) 
 end
 
 currentcave=mid(1,#caves,currentcave)
 if currentcave!=oldcave  or oldismap!=cave.ismap or level!=oldlevel then
  if (currentcave!=oldcave and cave.ismap) cave_compress()
  setinfo("cave "..level.."-"..currentcave.. " "..(cave.ismap and "map" or "list"))
  cave=caves[currentcave]
  global[[
oldcave=@currentcave
oldismap=@cave.ismap
oldlevel=@level
oldcavedata={}
]]
 end
 
 dif,oldcavedata=comparecopy(cave,oldcavedata)
 if (dif) render() oldline=nil
 
 curline,addline=mid(curline+addline,1,cave_len()+1),0
 if curline!=oldline or clearline then
  eheader,eline,etable=cave_str(curline) 
  oldline,eline,overwriteeline=curline,overwriteeline or eline
  if (cleareline) eline,cleareline="",false
 end
 
 if (curline>cave_len()) eline,etable="",{}
 

 
 if inputmode or listview then
  
  
  if (btnp⬅️) epos-=1
  if (btnp➡️) epos+=1
  epos=mid(1,epos,#eline+1)
  
 if (eheader=="name") nkey=keytrans[key] or key else nkey=key
  
  if key then
   if key=="del" then
    eline=sub(eline,1,epos-1)..sub(eline,epos+1)
   elseif #nkey==1 and nkey>=" " and nkey<="\127" and eheader!="" then
    eline=sub(eline,1,epos-1)..nkey..sub(eline,epos)
    epos+=1
   elseif key=="\8" and epos>1 then
    eline=sub(eline,1,epos-2)..sub(eline,epos)
    epos-=1
    
   elseif key=="\r" then
    if type(cave[eheader])=="boolean" then
     cave[eheader]=eline=="true"
    elseif eheader=="name" then
     cave.name=eline
    elseif tonum(etable) then
     cave[eheader]=mid(0,255,tonum(eline) or cave[eheader])
    else
     local t,off=split(eline), curline<=#header and 0 or 1
     for nb=1+off,#etable do
      local x=t[nb-off]
      if(tonum(x)) x=mid(0,255,x)
      if (type(x)==type(etable[nb])) etable[nb]=(x and tonum(block[x])) and block[block[x]] or tonum(x) or etable[nb]
     end
    end
    
   if (listview) addline=1 else inputmode=false

    oldline=nil    
   end
  end
  
 elseif cave.ismap then
  local kb=kblock[key]
  if (kb) curblock=block[kb]
  if (key!="shift" and wheel!=0) curblock=block[kblock[limit(kblock[block[curblock]]+wheel,0,#kblock)]]
  
  if mb==1 then
   if eheader=="player" then
    cave.player[1],cave.player[2]=cx,cy
   elseif mget(cx,cy)!=curblock then
    if cx>=1 and cy>=1 and cx<=gamew2 and cy<=gameh2 then
     mset(cx,cy,curblock)
     savemap=true
    end
   end  
  end
  if mb==2 then
   if eheader=="player" then
    cave.player[3],cave.player[4]=cx,cy
   else
    curblock=mget(cx,cy)
   end
  end
  
  if (mb==0 and savemap) cave_compress() savemap=false render()
  
  
 else
  
  local headerinfo=blockeheader[eheader]
  
  if key then
   
   
   local kb=kblock[key]
   if kb then
    
    if headerinfo==1 then
     etable[2]=kb
    elseif headerinfo==2 then
     etable[1+esel]=kb
    elseif headerinfo==3 then
     cave.random[esel*2-1]=kb
    end
   end
   
   if key==" " or kb then
    if headerinfo==2 then
     esel=esel%2+1
    elseif headerinfo==3 then
     esel=esel%4+1
    else
     esel=1
    end
   end
   
  end
  
  
  
  if mb==1 then
   local headerinfo=coordinateheader[eheader]
   if eheader=="player" then
    cave.player[1],cave.player[2]=cx,cy     
   elseif headerinfo==1 then
    etable[3],etable[4]=cx,cy
   elseif headerinfo==2  then
    etable[4],etable[5]=cx,cy
   end
   
  elseif mb==2 then
   local headerinfo=coordinat2eheader[eheader]
   if eheader=="player" then
    cave.player[3],cave.player[4]=cx,cy     
   elseif headerinfo==1 then
    etable[5],etable[6]=cx,cy
   elseif headerinfo==2 then
    etable[6],etable[7]=cx,cy
   end 
   
  end
  
 end
 
 
 
 
end

function box(x,y,c)
 if (not x) return false
 fillp(0x5a5a.0)
 
 rect(x*zoom-1,y*zoom-1,x*zoom+zoom,y*zoom+zoom,c|0xe0)
 
 fillp()
-- for i in all({-1,1,0}) do
--  rect(x*zoom-2+i,y*zoom-2+i,x*zoom+zoom+1-i,y*zoom+zoom+1-i,i==0 and c or 14)
-- end
end

function draw_editor()

 local ix,iy=0,121
 
 if listview then
  local y=listy
  for i=1,cave_len()+1 do
   local a,b=cave_str(i)
   x=print((headertrans[a] or a)..":"..(i==1 and level.."-"..currentcave or ""),0,y,5)+1
  if (i==curline) ix,iy=x-1,y else print(b,x,y,7)
   y+=7
  end
  
  if iy<=12 then
   listy+=7
  elseif iy>=120 then
   listy-=(iy-113)\7*7
  end
  listy=mid(0,listy,min(0,-cave_len()*7+122))
  
 else
  camera(camx*zoom,camy*zoom) 
  for y=0,gameh1 do
   yy=y*zoom
   for x=0,gamew1 do
    xx=x*zoom
    t=mget(x,y)
    if showsprite and zoom>2 then
     
     if t>0 then
     if (zoom<=6) t,z=z5spr[t],5 else z=8
      sspr(t%16*8,t\16*8,z,z, xx,yy,zoom,zoom)
     end
     
    else
     if (ecol[t]) rectfill(xx,yy,xx+zoom-1,yy+zoom-1,ecol[t])
    end
   end
  end
  
  box(cx,cy,1)

  local x1,y1,x2,y2
  if header_x2y2[eheader] then
   _,_,x1,y1,x2,y2=unpack(etable)
  elseif eheader=="player" then
   x1,y1,x2,y2=unpack(etable)
  elseif eheader=="rect" then
   _,_,_,x1,y1,x2,y2=unpack(etable)
  elseif eheader=="raster" then
   _,_,x1,y1=unpack(etable)
  end
  
  if(x1)box(x1,y1,15)
  if(y1)box(x2,y2,2)

  camera()
  
  

  printo(curline..":"..(headertrans[eheader] or eheader),0,128-7-7,5)


  printor("◆"..gems.." x"..butterflys,127,128-7-7,6)
  
 end
 
 if (not listview and eheader=="name") ix=printo(level.."-"..currentcave,ix,iy,5)
 
 if inputmode or listview then
  clip(ix-1,iy-1,128,128)
  local x=print(sub(eline,1,epos-1),0,0x8000)
  local xx=min(0,116-ix-x)+ix
  printo(eline,xx+1,iy,10)
  line(xx+x,iy,xx+x,iy+6,8)
  clip()
 else
  
  printo(eline,ix+1,iy,7)
  if eheader=="raster" or eheader=="all" or eheader=="rect" or eheader=="line" or eheader=="box" or eheader=="point" or eheader=="rect1" then
   local a,b=findx(eline,",",esel-1)+ix,findx(eline..",",",",esel)+ix-3
   line(a,iy+6,b,iy+6,2)
  elseif eheader=="random" then
   local a,b=findx(eline,",",esel*2-2)+ix,findx(eline..",",",",esel*2-1)+ix-3
   line(a,iy+6,b,iy+6,2)
  end
  

  if cave.ismap then
   t=z5spr[curblock]
   rectfill(mx+2,my+5,mx+8,my+11,14)
   if (t) sspr(t%16*8,t\16*8,5,5, mx+3,my+6,5,5)    
  end
  
--  local fn=mx>64 and printor or printo
--  fn(tostr(block[mget(cx,cy)]).." "..cx.." "..cy,mx+6,my+7,7)
 end
 
 if infotxt and infotimer then
  printor(infotxt,127,121,8)
  infotimer-=1
  if (infotimer<=0) infotxt,infotimer=nil
 end  
 
 spr(23,mx,my)

end


function setinfo(txt)
 infotxt,infotimer=txt,120
 printh(txt)
end

-->8
--test
function findx(str,f,c)
 if (not c or c<=0) return 0
 for nb=1,#str do
  if sub(str,nb,nb)==f then
   c-=1
   if (c<=0) return print(sub(str,1,nb),0,0x8000)
  end  
 end
 return print(str,0,0x8000)
end



global[[

z5spr={
--gem = yellow
3=15
--player = skin
5=25
--exit = 
19=47
--firefly=
7=14
--amoeba =
8=27
--butterfly=
9=13
--magicwall=
22=44
--slime=
11=63
--dirt=
16=29
--metal=
17=30
--wall=
18=31
--rock=
20=46
--moving-wall=
21=45
--magicwalleraser
24=28
}


ecol={
3=7
5=15
19=1
7=8
8=11
9=9
22=12
11=11
16=4
17=1
18=5
20=6
21=13

24=2
}

defline={
◆=point,vOID,1,1
⬅️=line,vOID,1,1,2,2
✽=rect,vOID,vOID,1,1,2,2
▒=box,vOID,1,1,2,2
➡️=raster,vOID,1,1,2,2,2,2
█=add,vOID,vOID,0,0
●=rect1,vOID,1,1,2,2
}

defnewline={
p=point,vOID,1,1
l=line,vOID,1,1,2,2
f=rect,vOID,vOID,1,1,2,2
b=box,vOID,1,1,2,2
r=raster,vOID,1,1,2,2,2,2
a=add,vOID,vOID,0,0
g=rect1,vOID,1,1,2,2
}


header_x2y2={
line=true
box=true
point=true
rect1=true
}

blockeheader={
line=1
box=1
point=1
rect1=1
raster=1
rect=2
add=2
random=3
}

coordinateheader={
line=1
box=1
point=1
rect1=1

rect=2
raster=1

}

coordinat2eheader={

line=1
box=1
rect1=1

rect=2

}


kblock={
"0"=vOID
"1"=dIRT
"2"=gEM
"3"=rOCK
"4"=wALL
"5"=wALLGROW
"6"=mAGICWALL
"7"=bUTTERFLY
"8"=fIREFLY
"9"=aMOEBA
","=sLIME
"."=sLIME
"/"=eRASER
"*"=mETAL
0=vOID
1=dIRT
2=gEM
3=rOCK
4=wALL
5=wALLGROW
6=mAGICWALL
7=bUTTERFLY
8=fIREFLY
9=aMOEBA
10=sLIME
11=eRASER
12=mETAL
vOID=0
dIRT=1
gEM=2
rOCK=3
wALL=4
wALLGROW=5
mAGICWALL=6
bUTTERFLY=7
fIREFLY=8
aMOEBA=9
sLIME=10
eRASER=11
mETAL=12
}

block2ascii={
0=" "
16="."
17=W
3=d
18=w
21=x
22=M
5=P
19=X
20=r
9=C
7=Q
8=a
11=s
24=k

" "=0
"."=16
W=17
d=3
w=18
x=21
M=22
P=5
F=5
X=19
r=20
C=9
c=9
B=9
b=9
Q=7
q=7
o=7
O=7
a=8
s=11
k=24
}

keytrans={
a=A
b=B
c=C
d=D
e=E
f=F
g=G
h=H
i=I
j=J
k=K
l=L
m=M
n=N
o=O
p=P
q=Q
r=R
s=S
t=T
u=U
v=V
w=W
x=X
y=Y
z=Z
█=a
▒=b
🐱=c
⬇️=d
░=e
✽=f
●=g
♥=h
☉=i
웃=j
⌂=k
⬅️=l
😐=m
♪=n
🅾️=o
◆=p
…=q
➡️=r
★=s
⧗=t
⬆️=u
ˇ=v
∧=w
❎=x
▤=y
▥=z
}


headertrans={
name=nAME
size=sIZE
intermission=iNTERMISSION
needed=nEEDED
time=tIME
amoeba_time=aMOEBA TIME
amoeba_fast=aMOEBA FAST GROW
amoeba_slow=aMOEBA SLOW GROW
amoeba_limit=aMOEBA LIMIT
magicwalltime=mAGIC WALL TIME
slime_permeability=sLIME PERMEABILITY
player=pLAYER iN/oUT
seed=sEED
random=rANDOM
point=pOINT
line=lINE
rect=fILLED
rect1=fILLED1
box=bOX
raster=rASTER
add=aDD
loopx=lOOP x
loopy=lOOP y
}

]]



function _test(fn,i)
 local c=0
 while fn(i) and c<15+3 do
  c+=1
  i+=1
 end
 return c
end

function cave_compress()
 local last,i=block_void,0
 cave.map={}

 while i<gamew2*gameh2 do
  local w1,w2=0,0
  
  c=_test(function(ii) return mget(xy(ii))==last end,i)
  if (c>w2) w1,w2=flag_last,c
  c=_test(function(ii) return mget(xy(ii))==mget(xy(ii-gamew2)) end,i)
  if (c>w2) w1,w2=flag_above,c
  c=_test(function(ii) return mget(xy(ii))==block_dirt end,i)
  if (c>w2) w1,w2=flag_dirt,c
  
  if w2>2 then
   add(cave.map,w1)
   add(cave.map,w2-3)
   i+=w2
  else
   last=mget(xy(i))
   add(cave.map,block2id[last])
   i+=1
  end
 end

end



__gfx__
00f00f000000f00000000f00000570000000000000f00f00e765e765222222220033bb3007000050ddddddeddddddddd55ee55ee070700002222200000700000
00ffff00000fff000000fff000d667002222222200ffff005eeeeeee2aaaaaa203bbbbb306700d60cdddddec11111111556e556e060600002999200005570000
0ffffff000fffef0000fffef099aaa70000000000ffffff06eeeeee72a9999a23bbbabbb0aa799a0cccccdec11111111555555550a7a000029a9200066667000
00ffff00000fff000000fff0dd6666672222222200ffff007eeeeee62a9449a2bbbabbbb0667d660eeeeeeee1c1121c155555555060600002999200009aa0000
00ccccf0000cc0000000cccf5eeeeee70000000000cccc00eeeeeee52a9449a2bbbbbbb300075000dddddedd1111111155ee55ee070700002222200000700000
0f0cc000000cfc70000ccc700dd66670222222220f0cc0f05eeeeeee2a9999a2bbbbbbb30667dd60dddddeccd11111dd556e556e000000000000000000000000
07700c0007c0070007c00700009aa7000000000000c00c006eeeeee72aaaaaa23bbbbb300a7009a0ccccdecc0d111d0055555555000000000000000000000000
000007700070000000700000000d700022222222077007707e567e562222222203bbb300070000d0eeeeeeee00ddd00055555555000000000000000000000000
444e444455555555e66666665555555500666700ee66666eeddddddd0e000000e11111110fff00000000000203b30000eeeee000444e400055555000eeeee000
e54445e45ee55ee5e55666665eeeeee506667760e5666666eccddddde7e00000edd111110fff0000220002203bbb3000e11110004544400056565000e6666000
4444444556e556e5e5555556575555e555666776ee55555eeccccccde77e0000edddddd1fcccf00000202000bbbbb000eddd10004444400055555000e5556000
44e5454455555555eeeeeeee575555e556676667eeeeeeeeeeeeeeeee777e000eeeeeeee0ccc0000220202203bbb3000eeeee00044e4400056565000eeeee000
4e44444e55555555666e6666575555e55656676666eee666dddedddde7777e00111e1111770770000002000203b30000111e10004444400055555000666e6000
44554e445ee55ee5666e5566575555e555666656666e5666dddeccdde777e000111edd1100000000000200020000000000000000000000000000000000000000
4444444556e556e5556e5555577777e50555655055eee555ccdecccce7ee0000dd1edddd00000000000200020000000000000000000000000000000000000000
4544544555555555eeeeeeee5555555500555500eeeeeeeeeeeeeeee0e000000eeeeeeee00000000000200020000000000000000000000000000000000000000
004e44440000444400000044000000000000000000000000444e4400444e000044000000444e4444444e4444444e4444eeeee000eeeee0000676000055555000
004445e4000045e4000000e4000000000000000000000000e5444500e5440000e5000000e54445e4e54445e4e54445e4edddd000e5555000666760005eee5000
004444450000444500000045444444450000000000000000444444004444000044000000444444454444444500000000ecccd000eeeee00056666000575e5000
00e54544000045440000004444e54544000000000000000044e5450044e500004400000044e5454444e5454400000000eeeee000eeeee0005565500057775000
0044444e0000444e0000004e4e44444e4e44444e000000004e4444004e4400004e0000004e44444e0000000000000000ddded000555e50000555000055555000
00554e4400004e440000004444554e4444554e440000000044554e00445500004400000044554e44000000000000000000000000000000000000000000000000
00444445000044450000004544444445444444454444444544444400444400004400000000000000000000000000000000000000000000000000000000000000
00445445000054450000004545445445454454454544544545445400454400004500000000000000000000000000000000000000000000000000000000000000
000aa000000a000000000000000000000000000000000000000000000000000000000000000000022000002200000002000000020000000000000000ddddd000
0aaaaaa0000aa0000000900000000000000000000001100001000010222222222222222222000220022022002200022022000220222222222222222211111000
0a888aa000aaaa000009900000000000000110000000010000000000000000000000000000202000000200000020200000202000000000000000000011111000
aa88888a0a888aa000922900000220000010010001000000100000012222222222222222220202200002000022020220220202202222222222222222d111d000
aa88888a0aa888a0099229000002200000100100000000100000000000000000000000000002000200202000000200020002000200000000000000000ddd0000
0a8888a00aa8aa000009990000000000000110000010010000000000222222222222222200020002220002200002000200020002222222222222222200000000
0aa8aaa0000aaa000000000000000000000000000001000001000010000000000000000000020002000000020002000200020002000000000000000000000000
000aa000000000000000000000000000000000000000000000000000222222222222222200020002000000020002000200020002222222222222222200000000
00f00f000000000000000000000d70000000000000f00f00765e765eaaaaaaaa03bbbb3070000005eddddddddddddddd5555555570007000aaaaa00000500000
00ffff000000f00000000f00009aa7002222222200ffff00eeeeeee7a999999a3bbbabb3670000d6eccddddd111111115ee55ee567066000a999a00006670000
0feffef0000fff000000fff00dd66670000000000feffef05eeeeee6a944449abbabbbbbaa70099aeccccccd11c1111156e556e5aa7aa000a949a0009aaa7000
00ffff0000fffef0000fffef5eeeeee72222222200ffff006eeeeee5a942249abbbbbbbb6667dd66eeeeeeee11111c115555555567066000a999a00006670000
0fcccc00000fff000000fff0dd6666670000000000cccc007eeeeeeea942249abbbbbbbb00075000dddedddd111111115555555570007000aaaaa00000500000
000cc0f0000cc0000000cccf099aaa70222222220f0cc0f0eeeeeee7a944449abbbbbbbb66700dd6dddeccddd112111d5ee55ee5000000000000000000000000
00c0077007cfcc0007cccc0000d667000000000000c00c005eeeeee6a999999a3bbbbbb3a700009accdecccc0d1111d056e556e5000000000000000000000000
07700000070007700700077000057000222222220770077067e567e5aaaaaaaa03bbbb307000000deeeeeeee00dddd0055555555000000000000000000000000
00f00f000000f00000000f00000970000000000000f00f0065e765e79999999903bbb30007000050ddeddddddddddddd55555555070700009999900000700000
00ffff00000fff000000fff000d667002222222200ffff007eeeeee6944444493bbbbb3006700060ddeccddd1111111155555555060600009444900009aa0000
0feffef000fffef0000fffef05eeee70000000000feffef0eeeeeee594222249bbbabbb30aa709a0cdeccccc11111111ee55ee550a7a00009424900066667000
00ffff00000fff000000fff0dd6666672222222200ffff005eeeeeee942aa249bbabbbbb0667dd60eeeeeeee111c11116e556e55060600009444900005570000
00ccccf0000cc0000000cccf99aaaaa70000000000cccc006eeeeee7942aa2493bbbbbbb00075000deddddddd1211c1155555555070700009999900000700000
0f0cc000007cf000007cc0000dd66670222222220f0cc0f07eeeeee69422224903bbbbbb06670d60deccdddd0d11111d55555555000000000000000000000000
07700c000007c0000007c000005ee7000000000000c00c70eeeeeee59444444903bbbbb30a7000a0decccccc00dd11d0ee55ee55000000000000000000000000
000007700000770000007700000d70002222222207700700567e567e999999990033bb30070000d0eeeeeeee0000dd006e556e55000000000000000000000000
00f00f000000f00000000f00000d70000000000000f00f005e765e7644444444003bb30000700500ddddeddddddddddde556e556007000004444400000900000
00ffff00000fff000000fff0005ee7002222222200ffff006eeeeee542222224003bbb3000600600ddddeccd1111111155555555006000004222400006670000
0ffffff000fffef0000fffef0dd66670000000000ffffff07eeeeeee42aaaa2433bbbbb300a79a00cccdeccc11121c115555555500a0000042a2400055557000
00ffff00000fff000000fff099aaaaa72222222200ffff00eeeeeee742a99a24bbbbabbb0067d600eeeeeeee11111111e55ee55e006000004222400006670000
0fcccc00000cc0000000cccfdd6666670000000000cccc005eeeeee642a99a24bbabbbbb00075000ddddddde11c11111e556e556007000004444400000900000
000cc0f0000fc700000cc70005eeee70222222220f0cc0f06eeeeee542aaaa243bbbbb330067d600ccdddddedd111ddd55555555000000000000000000000000
00c00770000c7000000c700000d667000000000000c00c707eeeeeee4222222403bbb30000a00a00ccccccde00d11d0055555555000000000000000000000000
077000000007700000077000000970002222222207700700e567e56744444444003bb30000700d00eeeeeeee000dd000e55ee55e000000000000000000000000
00f00f000000f00000000f00000570000000000000f00f00e765e765222222220033bb3007000050ddddddeddddddddd55ee55ee070700002222200000700000
00ffff00000fff000000fff000d667002222222200ffff005eeeeeee2aaaaaa203bbbbb306700d60cdddddec11111111556e556e060600002999200005570000
0ffffff000fffef0000fffef099aaa70000000000ffffff06eeeeee72a9999a23bbbabbb0aa799a0cccccdec11111111555555550a7a000029a9200066667000
00ffff00000fff000000fff0dd6666672222222200ffff007eeeeee62a9449a2bbbabbbb0667d660eeeeeeee1c1121c155555555060600002999200009aa0000
00ccccf0000cc0000000cccf5eeeeee70000000000cccc00eeeeeee52a9449a2bbbbbbb300075000dddddedd1111111155ee55ee070700002222200000700000
0f0cc000000cfc70000ccc700dd66670222222220f0cc0f05eeeeeee2a9999a2bbbbbbb30667dd60dddddeccd11111dd556e556e000000000000000000000000
07700c0007c0070007c00700009aa7000000000000c00c006eeeeee72aaaaaa23bbbbb300a7009a0ccccdecc0d111d0055555555000000000000000000000000
000007700070000000700000000d700022222222077007707e567e562222222203bbb300070000d0eeeeeeee00ddd00055555555000000000000000000000000
c896e44525fca2612141a1814187e646a505e1c380048c02805020e08c80fef96600c3412330900000421010a04142b0104141425110e14142f1108241008011
90423160e0c081b031b0c0d0b080b0317060d0b090b090c0e05181b08170d10181b081011122428160e060311190c090a1e0608160d0b0906122215180012201
90703160d16070e0b0e0608151c260e001900008c61424952594e4458c61824161d191418c0ac88746e1c380048c0210624110f78361b297418721a500e130a0
006131800181616080b070e0c090b0e070c181c09070e07080b0806021c08060d1c0b0e060e080b031c170e06031c0e0d0b0217032d0e0b08170d1c08111e070
31607101e0b0d0d1c081018070e070d07021b071c0d070e070e0c09060e0c0e070e070d070d01190c0711131037062e080b00370e0b0d03180b0627021c07101
3170e0b09001d05111907090c03170e070d1c0f18090c0e0c0220161726063700008c6f4f40d0161103050605087e646a505e1c380048c02503110103745cdd7
c2000000000000000035101010a0203095201010a0103005301010a010304510202080103000501070d011e0f1d06090b0119070e01002711181246131a010c0
21c03192113152211131246131f010c021c031926131a01002711181246181501011d0c0e0e2000807944d82614191e132828ceb4baa0ae1c380048c02602022
202ef5d3839a41a500e17060304042602011d04271d012305211f071f0960000100060900112b0d0c090b1d070b2c0211190c0d00290c0d09011d07090019011
6090609060806090d0013170d07060709060e06021019061808331b0e0608170e001e0b02202d01070d07030c0806030c0d030c0d01080c0d0c081b080708160
9060e080b03160e0b080c08060b12160c0d070e01190b090b09011d0c0d0600290c001d0c031119060e011d06070907090a121a190c0603180b0e0b16201e011
e09212c0c1b0c3708170e060711190105020e00131c0e0b0c0429001900190f1c111d07062c0d070212574e1619043d06090929002804290b08090f2d0119070
8161e06031c031703160d0c08160e060e070e000286614c4c494e4740246f475ec01016060606060a0a0a0a0a0e1c304808c023070e0e0001020304000000000
00000000070000010181a0e071a06011a070005246a1b2a201610088d6144525948d8221a0f04191e187e646a505e1c380048c02108062803313bea94741ff30
4b0000000016300000171010900102a010910117a110620102a090110102211091802210109010221001900122a110621022a101620100a2f0c0d25291c0b461
3784000876551425443d726150607090a04baa0a69c8e1c380048c02310131f06cd8f148d5414300000000000023009000d1f022311031e025a0304140103035
01202050603095f02020508030059010205041300590202050413015801020f0611000b0d0f190b021f1e0b08070806190019011e0b08060d0b0907051901190
7051900290f190026090a190026090a1900290f1900290f1900290429070e0b19042c0f370d061450193d0925080f080a28092803280a2809280e1d0a2928091
d0a2922143e0709000c827f4f4d43d6241f3a374d4448c4b0ac887e1c380048c02203051f0b5ae01876341280005308200004210c042c0421021422142106042
60426010602142c010c0214221102121428110812142e110e1214242104221156030603060601530606030606000d060e011b090609080c060e070e060e07081
7090b080b0c021726011b0e060e0b1d01190c080e060e060e06011b03101c031b0e061a190702170906090119070216011e01160e060e0800190c060e060e080
11806081c001e080b0e17071702170d0316031603170d1b07060a0c09011809051d0c080c0b0906002d061b0c031b090c06071013170907031209001e0c060e0
60e070e0d061e011c2700181c0e06011906090a0b18090c0b0d06031b1b0312001817080c06081017080c0e0b0703253b0d0e0c06070d1d30048075534bc4161
406070808087e646a505e1c380048c02b0a090a0000000000000ff00000000000027302040302760208030223050405022107040702260506090227070807027
8050c05022a060a07022c070d07022e050e09022a010a03027c020e0302210101060270120113022017021702201501150214080221090409022019021902480
90c0b02210b040b02260b060d02280d0c0d022e0b0e0d02101802201b021b02101c02201d021d02140c02210d040d02230f040f02260f080f022a0e0a0f022c0
f0e0f02201f011f02210e01041226011602122e011e021228011c011223031803122c03111312201010111224001401121211121201122a021a03112a090a0a0
352020202001019140e081a0018101e091604081e04091a040360100103560e02020802000b0e070e0c0e0b1314221b031921261b27051d0c0d0b02152e0b0e0
60f2e011d0b0d0c071310181b0e0f18111d060002846941474f4e414cc0101c0c0c0c0c0a0a0a0a0a0e1c304808c021050e05000102030400000000000000000
23111010e030231110c0e0e072104070a07280a0e04072107050b072a0b0e07032106060b03290b0e06092204070900080708070807080708070801190709070
907090709011900008a6554474d454e4450246149d8261a04182c30587e646a505e1c304808c0221a021009ea0dd902641c3000000000000a2f0b051b0841010
6241742020523100b03151e0517071c0d0c0620190b1801190018060e0f1908421b0e060809042e0f221c0d03160802270d031b0c0d0b0d0b090c0e060c09051
c090c07160805161e0d0d3e08070602270e06031112102ffb4e002217012c0d0b03160316078a1312160f0c080b080618070a1c0d01190b0c2608001e043d0c0
f0a181f060a02170e0a08050905090a190008886f4552574c414353d7161204080c04187e646a505ffc380028c0280e0e0e0d58ccd879141ff30080000000007
1020905142101090a007d020514142104190b042d0a0511042d0b0514152a080c080560000ffb2a0b0c0b0001260c1b0e0b0809011d102810008265545455425
64c494543d7261a0f04191e187e646a505e1c380048c0231f031009b34e4f18c4141000000000000074011223185401101202020143001324100c0b0307260d1
61217371ffd281a1801180018061d0b0805172612200c816655425c414e434845c224150a0f041e187e646a505e1c380048c02f0b0f1b0000000000000ff0000
000000004520208040406045405080404060463000ff3621ff00008070a06180b0f0105010a010a0e08070821180326070b08210c0b0c0901180d210a01050b0
c090e16190002836942534c45c010140404040409141f0f0f0e1c304808c021020e0a0c99f80ef88000000000000000003303030505003308030a05003303070
509003308070a09091503091a0308130708180700021819371b0f00191b0a05171c0f011f0c0410280000837e41494cc5151c0c0c0c0c069c8288746e1c38004
8c02a010a0a0854ab1543d00000000000000003210103131321031311007109031b044202021214440400101446060e0e043008080c0c09530a08010202001a0
c001a00101a02001a06000e2d5c5e5e2d042718184c1d14231d0529474817152e0a1e0d093e0d033e0f09021b1d0b0c0e0a16393d0e051d0b0d070d001023090
01d1d01112427091c03100084794d494e47c8261e13282d22387e646a505e1c304808c0230a0724087e4dd6aad00000000000000000710405080713010811060
07b0b0f0f0049090111142a0a001a07271e081e08181d09171d02210c040c022e110e10171e01071e0300751209160714120624170a1702412c072510722d062
111222c062c01142d0812211c232c052c081d0b07142c08171200730d070118130f022a010a06007f130226071421081026000801101e5b0c1c060d070d070e0
807090c0608070210170b21101d1e63132703212b0d0c0b011e07013d0c060e06190708170e10360807001801160d170d0c09011d031936081c0b07031c0b070
90b0c062e213c080f0b0c0502151807021b0a3a2228060807071b0220111d06031b0c07111d001e0d0118111d0111311b2c071c2b091c0c160c0d060e060d0c0
31c0547000084654d4f4c4944594f4ec8261a0a05070502debaa6928e1c304808c02a1704251fa97def7de41e130500000000042601060414270a041a042e0b0
e04142b050d150178160c14122d160d1412271a0714104b131c14104b101c11104b1d0c1e004b1a0c1b0048131914104810191110481d091e00481a091b09591
a02040203042e1b022b042221022b0006061b08090b0e0d0013160d001318001e070d070900190b08001e0c0d070906071e051118151b1e0d0901190b1d06190
01c0d0c080b1121190b09011b090c0b090603101e01180b0804290b09051b1d052a1900190a18051c1c090b1d01180b130909290f13161e0028011807080b1d0
702111311981c101e0a190f1e051d0a12152d06121b0c080c060c111d001211101e0709080b0d001d121c08060e07060e070e0d011d060c01311213031016242
e037c0f0b0b28142e012b022c012b031c022b080e0c080012161d0f27211c1302201b27481d7c0916071b0d0b0c270b09070b2613111809363d3d1e380708052
2111801162a162b180000837b494050294451a5101e13282d22387e646a505e1c304808c02103041300000000000000000000000000005504060b02010755020
601020208250e0f04015404070b0201000116420f57150d050805060d084511180248025b37000280725943594f4ec010110101010109191919191e1c304808c
02303020a052320dc13e000000000000000073705020b08031806000626190d0c014b0199070e190b12133119070429070000000000000000000000000000000
__gff__
00000007000001010101010100000000011105150f0101000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a0a9020000000000000000000000000000000000000000000000000000000000a00609000000000000000000000000000000000000000000000000000000000018001800
000000000000000000000000000000001900000000000000000000000600240000000000000000000000000000000080a60600000000000000000040020060a50205000000000000000000000000009000a9000000a40100000000c00000801aa9ea00000040a9aaaa0200000000009000401a0000590a000000009000000000
1040020040aa060000a9aa05000000800000a401400264000000006000bdaa0200000200a8010000000050ea1ac01a900000000a800090000000003000fdff0f000006000900000000000000a43aa46a00000018750080000000002400fdff7f000019e4025500000000000000140000000000b00a0080010000001800fdffff
0100a45a40ff2f00000000000000d0afaa0a0000000040020000000800feffff07040000d0ffbfac01000000000050e9ff0f1900000140020000000c0015feff1ffe1600e0fffffe0b000000000000e0ef9f1f00e0030002000000180000ff8bbfbfff01f8fffffa4b550000000000f0dfef1f00fc034002000000a00140ff5b
7e07fd01fdaffffbcbffb9aa6a5555f4dbab1f00fc93aa01000000802e40ffff3e07fd01ff8ffffb8f6ff6fffffffff8d78b1f00f463150000000000a480bfd52f0afd81ff87aafb4f7ff2fffffffffdd38f1f00f03300000000000080c2ff69290efde1ff0200f40f7fe0fffffffffde28b1f00f03200a90100000040d2ffbd
001dfdf5bf0000f41fbfa0fdffffbfffe18b0f00f42240460a00000080e1fff5011cfcf97f0055f4bfbf50fd03557effe0cb0f00f462a4001c000000c0e0ffe003b8fdfabf05fff4ff5b00fc070089bff9cb0f00f4921a002400000090f0bfd007f4fffeffaffff11ff906feab06c0bfe6cb0f00f40200002000000060f47f80
0ff4ffa6fffffff21ffc03feff03d03fe0cb0f00f40200003000000030f83f001a40fa02e4ff6ff12ffd02f40f00e01fe0c70fa5f60254002000000020903e000000500100e501e02ffe01f01f00f00fa0d5fffff9a63f00300000002400100000000000000000e02fff00e02f40f90bf0efffbff8ff2f002400000024000000
801b0000005400e07fbf05d01be05b00f0efff6ff8ff0f151900000064010000a9a40000b9ea00903fbd068001000000f0da6b01f8af45fa0700000090aa0180064007400280010024d0020000000000100000005400c0500000000000401a9000006aa5008001000000010000a80500000000000000d000000000000000e42a
0000801a00400200000000000043ba01000000000000600000000000000000000000000000006a01901a00000006500600a95a0000507900000000000000000000000000000094aa6ba5aa01400200184007a40294aa060000000000000000000000000000000000000054aaab0000e0aa0000aa6a0000000000000000000000
00000000000000000000004014000000000000546306336030c3038331980100000000006306336030e307c371f801000000000063c6fff8016306e3e0f0c0000000000063c6fff881630663c060c0000000000003003378c0c11360c0f8f103fc00000003003378e0c01b60c0f8f103fc00000000c0ffe071600e60c060c000
0000000000c0ffe031600ee0e0f0c00000000000030033f831e31fc071f8016000180000030033f831c31380319801600018000000000060000000000000006000000000000000600000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000607860f0e1c38c1f1e7e78f00000000060fc70f0e3c78c1f1f7efcf80100000030cc780003c68c010360cc983100e30130cc780003c68c010360cc983180e30118cc608083c38f0f1f3078f801c6000018cc60c081c38f1f3f3078f001c600000ccc60e000060c183330cc803180e3010ccc607000060c183318cc8031
00e30106fcf8f1e3078c1f3f18fcf0010600000678f8f1e3038c0f1e1878f0000600000000000000000000000000000006000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f7800600000180030001830
180306001ffc00600000180038001830180306063086f1e1830f1f1e18f818000033060e3086f1e3c78f1f3f18fc1800003b06181ce60163c68019337eccf830181f06180ce6e163c680193f7eccf831181f060e0c06f063c680191f18fc9831183b060600063063c680190318f89831183306000c7cf0e3c78f1f3f18c09831
18331e000c78e0e3830f1f3e18c098311c331c000000000000000000007800000e0000000000000000000000003800000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000c000000000
000000fec3070f1f7c3cf0f163c68c81316306fec78f1f3f7e7cf8f163c68c8131630666c68c193366cc18c060c68c81e1610666c68c193366ccf8c060c68c81c1600666c68c1933660cf0c160c68c99e1610666c68c1933660c80c1608687bd31e30766c68c1f3f7e0cf8c1e38787e731c30766c60c0f1f7c0cf880c30303c3
3003060000000003600000000000000000e0030000000003600000000000000000e001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003c063c180060e0e1838f073f7ef803003c063c3c00e0f0e3c78f0f3f7efc037e0c0c306600c03163c6801903
060c007e0c0c306600803163c6801903060c00700c1830000000f0e3c380190f1ecc03380c1830000000f0e3c380190f1ecc031c0c30300000003063c6801903060c030e0c30300000003063c6801903060c037e3c603c00fc0030e3c78f0f3f06fc037e3c603c00fc0030e3838f073f06f80100000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000660c1833060c8c61f8e1831f3ef8f801660c1833061c8e61fce3c73f7efcf801660c181b063c8f630c63c630660c6000660c181b06fc8f670c63c63066
1c60007e0c180f06ec8d6f0ce3c7303e3860007e0c180f06cc8c7d0ce3c3303e706000668c191b060c8c790c63c03066e06000668c191b060c8c710c63c03c66c06000668c1f337e0c8c61fc63c03f66fc6000660c0f337e0c8c61f861801f667c60000000000000000000000000380000000000000000000000000000003000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000086318c813163c60f1ee301001e00000086318c813163c60f1ee301001e00000086318c813163060c068301001e00000086318c81e1e1070e078303001e00000086318c99c1c003870300073300
00000086318cbde18181830300873f0000000086718eff3183c1010783c31f0000000086e187e73183c1000683c10c00000000fec183c33183c10f1ee3010000000000fc8081813183c10f1ee301010101000100000005050000000000000a1f0a1f0a0000000207030607020000050402010500000002050e050e0000000101
0000000000000201010102000000010202020100000005020702050000000002070200000000000000000101000000000700000000000000000001000000040402010100000002050505020000000203020207000000030402010700000003040204030000000505070404000000070103040300000006010305020000000704
0402020000000205020502000000020506040300000000010001000000000000010001010000000201020000000000030003000000000001020100000000030402000200000006090d01060000000003060507000000010305050300000000060101060000000406050506000000000205030600000004020702020000000006
05060403000001010305050000000100010101000000020002020201000001050305050000000101010102000000000f1515150000000003050505000000000205050200000000030505030100000006050506040000000305010100000000060306030000000207020206000000000505050200000000050505030000000011
11150a0000000005020505000000000505050603000000070603070000000301010103000000010202020400000003020202030000000205000000000000000000000700000002040000000000000205070505000000030503050300000006010101060000000305050503000000070103010700000007010301010000000e01
0d090600000005050705050000000101010101000000040404050200000005050305050000000101010107000000111b151111000000090b0f0d09000000060909090600000003050301010000000609090d06080000030503050500000006010204030000000702020202000000090909090600000009090905020000001111
151b1100000005050205050000000505020202000000070402010700000006020102060000000101000101000000030204020300000000000a0500000000030304050700000100000000000000000000602000617700060600000000006677070100000060072700000000200070700000000010600020111000102100000671
__sfx__
4a0600001c67120661186510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
140800003f75500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
480200003f6703f6703a67036670346702c6701d670016700e6500e6500e6500e6400e6400e6300e6300e6300e6300e6300e6300e6300e6300d6300d6200d6200d6200c6200c6200c6200c6100d6100c6100d600
18020800335772f577245771957704000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000
020800002a6352a6051d6351d60512605000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000000000
780508000317206172081720a1720a1720a1720020000201002010020100201002010020100201002010020100201002010020100201002010020100201002010020100201002010020100201002010020100201
7a0709003e6313c651376613264127621000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7a0709002663131651376613c6413f621000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
160303000575101721000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b00a0020045460754609546025460b5460454605546005460954602546045460554608546055460b54602546075460054606546045460754609546025460b54604546055460254609546045460b5460054607546
400a0010210221d02218022150221f0221b0221602215022210221d02218022150221f0221b022160221502200000000000000000000000000000000000000000000000000000000000000000000000000000000
010f00000c5750c515000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f00001057510515000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
31110000105751051500000000000c5550c51500000000000854208512000000000004532045120000000000015120151200000000000c5050c5050000000000105051050500000000000c5050c5050000000000
7a0900203b7253e72531725377253a725377253c725377253f72536725357253f725397253172535725397253d725337253b7253172532725337253b7253e725367253b7253d725357253e7253a7253572535725
0008000011151181511d1512014500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
480200001d6712c6712566122661206611b651166310f621000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00140000110552d055110552e0551d0552d055110552e0550f0552d0550e0552e0551a0552b0550e0552c0552905524055210551d05527055220551f0550e055300552d0552905524055220551f0551b0550e055
00140000291552915529155291552915529155291552915529155291552915529155271552615526155261552d1552915524155211552b15527155221551a1552d1552915524155211552b15527155221551a155
00140000110552d055110552e0551d0552d055110552e0550f0552d0550e0552e0551a0552b0550e0552c055110551105511055300551d0551d055110552c0550f0550e0550e0550e0551a0551a0550e0550e055
0014000029155291552915529155291552915529155291552915529155291552915527155261552615526155291553515529155331552915532155291553015527155321552615532155261552e1552615532155
001400000f0550e0550e0550e055170551705517055170550c055240550c055240550a055090551105511055110551105511055110551d0551d05511055110550f0550e0550e0550e0551a0551a0550e0550e055
001400001b15526155161551d1552315532155261552315518155281551a1552915522155211552d1552115529155291552915529155291552915529155291552915529155291552915529155291552915529155
0014000011055180551d055200550f0551a0551b055220550d0550c055180550c0551b0552e0551c0552c055110551105511055110550f0550e0550e0550e0551105511055110551105519055180551805518055
011400001d1552115524155291551f15522155241552b1552515527155291552c155261553215528155301551d15529155181551f1551b1552b1551f1551a1551d15529155181551f15525155351552915524155
__music__
01 3f3e7f7f
00 3d3c7f7f
00 3b3a7f7f
02 39387f7f
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
00 40404040
__meta:4f78820c-0dc1-11ed-861d-0242ac120002__
@5f10
000102030405060708090a0b0c0d810f
__meta:1bdaec14-d23c-4c68-9cbb-45d80342eabf__
{
}
