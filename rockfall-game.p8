pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
--rockfall
--  by gpi

edition,
author
=
"",
"gpi"

----

cartdata("3e55a5f5fba544bf81884139723d1cda-rockfall-"..edition)

_sgn=sgn function sgn(a) return a==0 and 0 or _sgn(a) end

function limit(x,low,high)
 return (x-low)%(high-low+1)+low
end

function printo(s,...)
 for i in all(split'\-f\fe,\-h\fe,\|f\fe,\|h\fe') do
  ?i..s,...
 end
 return ?s,...
end

function printoc(s,x,...)
 return printo(s,x-print(s,0,0x8000)\2,...)
end
function printor(s,x,...)
 return printo(s,x-print(s,0,0x8000),...)
end

function printbigc(s,x,y,c)
 local w=0
 s=tostr(s)
 if x>=0 then
  for i=1,#s do
   w+=(fontbig[ord(s,i)] or fontbig[32])[3]-2
  end
  x-=w\2
 else
  x=-x
 end

 global[[
poke(0x5f54,0x80)
]]
 for b in all(blackborder) do
  local xx=x
  local dx,dy=unpack(b)
  pal(7,dx+dy==0 and c or 14)
  for i=1,#s do
   local tx,ty,tw=unpack(fontbig[ord(s,i)] or fontbig[33])
   sspr(tx+dx,ty+dy,tw,14,xx,y+1)
   xx+=tw-2
  end
 end 
 global[[
pal(7,7)
poke(0x5f54,0x00)
 ]] 
 
 return x+w
end


function usplit(...)
 return unpack(split(...))
end

function tstr(t)
 if (type(t)!="table") return tostr(t)
 local s=""
 for v in all(t) do
  s..=","..tostr(v)
 end
 return sub(s,2)
end

function tcpy(t)
 return {unpack(t)}
end
function tsub(t,a,b)
 local r={}
 for i=a,b or #t do
  add(r,t[i])
 end
 return r
end
function tsplit(t,a)
 local r={}
 for i=1,#t,a do
  add(r,tsub(t,i,i+a-1))
 end
 return r
end

function _tableat(v)
 local x=_ENV
 for l in all(split(sub(v,2),".")) do x=x[l] end
 return x
end

function table(str,t)
 local oldt,vt,tsave={}
 t=t or {}
 for l in all(split(str,"\n")) do
  if l!="" and sub(l,1,2)!="--" then
   local k,v=usplit(l,"=")
   
   
   if k=="}" then
    t=oldt[#oldt]
    deli(oldt)
   else
    if (not v) k,v=#t+1,k
    local kk,vv=usplit(v,"(")
    if vv then
     vv=table(sub(vv,1,#vv-1)..",")[1]
     deli(vv,#vv)
     t[k]=_ENV[kk](unpack(vv))
     
    else
     tsave=t
     if ord(k)==34 then
      k=sub(k,2,#k-1)
     else
      
      repeat 
       local a,b=usplit(k,".")
       if(b) t=_ENV[a] k=b
      until not b
     end
     
     vt=split(v) 
     if #vt>1 then
      for k,v in pairs(vt) do 
       if (ord(v)==64) vt[k]=_tableat(v)
      end
      t[k]=vt
     elseif ord(v)==64 then
      t[k]=_tableat(v)
     else  
      t[k] = ord(v)==34 and sub(v,2,#v-1) or ord(v)==123 and {} or v=="true" and true or v!="false" and v or false
      if (v=="{") add(oldt,t) tsave=t[k]
     end     
     t=tsave
     
    end
   end
   
  end
  
 end

 return t
end
function global(str) table(str,_ENV) end

function call(name,...)
 if (_ENV[name]) return _ENV[name](...)
end  

global[[
maxleveladr=0x223c
maxlevelsize=0x123c


statmin=9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9
statmax=0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

gemsound=0xfc,0xfa,0x4f,0xf9,0xff

cave_flags={
ismap=0x01
intermission=0x02
loopx=0x04
loopy=0x08
valid=0x80
}
cave_flag_valid=0x80

startcave=1
startlevel=1
speed=2

speedframe=6,8,12,16,20,24

blackborder={
1=-1,0
2=1,0
3=0,-1
4=0,1
5=0,0
}

fontbig={
32=0,2,7
33=7,2,5
34=12,2,9
35=21,2,13
36=34,2,9
37=43,2,9
38=52,2,11
39=63,2,5
40=68,2,7
41=75,2,7
42=82,2,9
43=91,2,9
44=100,2,5
45=105,2,9
46=114,2,5
47=0,17,9
48=9,17,9
49=18,17,9
50=27,17,9
51=36,17,9
52=45,17,9
53=54,17,9
54=63,17,9
55=72,17,9
56=81,17,9
57=90,17,9
58=99,17,5
59=104,17,5
60=109,17,7
61=116,17,7
62=0,32,7
63=7,32,9
64=16,32,11
65=27,32,9
66=36,32,9
67=45,32,9
68=54,32,9
69=63,32,9
70=72,32,9
71=81,32,9
72=90,32,9
73=99,32,5
74=104,32,7
75=111,32,9
76=120,32,7
77=0,47,13
78=13,47,9
79=22,47,9
80=31,47,9
81=40,47,9
82=49,47,9
83=58,47,9
84=67,47,9
85=76,47,9
86=85,47,9
87=94,47,13
88=107,47,9
89=116,47,9
90=0,62,9
91=9,62,7
92=16,62,9
93=25,62,7
94=32,62,9
95=41,62,9
96=50,62,9
97=59,62,9
98=68,62,9
99=77,62,9
100=86,62,9
101=95,62,9
102=104,62,9
103=113,62,11
104=0,77,9
105=9,77,5
106=14,77,9
107=23,77,9
108=32,77,9
109=41,77,13
110=54,77,11
111=65,77,11
112=76,77,9
113=85,77,11
114=96,77,9
115=105,77,9
116=114,77,9
117=0,92,11
118=11,92,11
119=22,92,13
120=35,92,9
121=44,92,9
122=53,92,9
123=62,92,9
124=71,92,5
125=76,92,9
126=85,92,11
}

block2id={
0=0
16=1
17=2
3=3
18=4
22=5
24=6
20=7
9=8
7=9
8=10
11=11
21=12
5=1
19=1
}
id2block={
16
17
3
18
22
24
20
9
7
8
11
21
0=0
}

flag_last=13
flag_above=14
flag_dirt=15
flag_first=13


demodiv=5
demomaxstep=51
demomove={
0=s
1=l
2=r
3=d
4=u

s=0
l=1
r=2
d=3
u=4
}


livesforscore=500

indexmem=0x2081,0x20a1,0x20c1,0x20e1,0x2b01,0x2b21,0x2b41,0x2b61,0x1581,0x15a1,0x15c1,0x15e1

_frame=0

allowed_move={
0=true
16=true
3=true
}

amoeba_move={
0=true
16=true
}

is_enemy={
9=true
7=true
}

enemy_touchexplode={
5=true
8=true
11=true
}

enemy_notattach={
0=true
9=true
7=true
}



flag_visible=1

is_fallable={
3=true
131=true
20=true
148=true
}
is_glide={
18=true
146=true
3=true
131=true
20=true
148=true
}
is_moveable={
20=true
}
is_indestructible={
19=true
147=true
6=true
134=true
17=true
136=true
}


sfxnb={
rock=0
gem=1
explosion=2
collect=3
steps=4
exitopen=5
spawn=6
exit=7
bonus=8
amoeba=9
wallmagic=10
ding=11
dong=12
timeout=13
trans=14
oneup=15
burning=16
highscore=17
}
sfx_rock=0
sfx_gem=1
sfx_explosion=2
sfx_collect=3
sfx_steps=4
sfx_exitopen=5
sfx_spawn=6
sfx_exit=7
sfx_bonus=8
sfx_amoeba=9
sfx_wallmagic=10
sfx_ding=11
sfx_dong=12
sfx_timeout=13
sfx_trans=14
sfx_oneup=15
sfx_burning=16
sfx_highscore=17

anim={
0x0800
0x0a00
0x0c00
0x0e00
explosion=48,49,50,51,52,53,54
plyright=65,81,97,113
plystand=69,69,69,69,69,69,69,69,69,69,69,69,69,69,69,69,69,117
plyboring=85,85,85,69,69,69,85,85,85,69,69,69,85,85,85,69,69,117
plymove=66,82,98,114
plyup=96,117,112,117
plydown=64,69,80,69
wallmagic=67,20,83,20,99,20,115,20
dirtleft=32,33,34
dirtdown=35,36,37
dirtright=38,39,40
dirtup=41,42,43
inbox=19,19
}

block={
void=0
VOID=0
vOID=0
space=0
SPACE=0
sPACE=0
dirt=16
DIRT=16
dIRT=16
metal=17
mETAL=17
METAL=17
steelwall=17
sTEELWALL=17
STEELWALL=17
steel=17
sTEEL=17
STEEL=17
gem=3
gEM=3
GEM=3
wall=18
wALL=18
WALL=18
wallgrow=21
wALLGROW=21
WALLGROW=21
wallmagic=22
wALLMAGIC=22
WALLMAGIC=22
magicwall=22
mAGICWALL=22
MAGICWALL=22
wallmagicon=10
eraserwall=24
ERASERWALL=24
eRASERWALL=24
walleraser=24
wALLERASER=24
WALLERASER=24
eRASER=24
ERASER=24
player=5
pLAYER=5
PLAYER=5
inbox=5
exit=19
outbox=19
exitopen=6
rock=20
ROCK=20
rOCK=20
boulder=20
bOULDER=20
BOULDER=20
butterfly=9
bUTTERFLY=9
BUTTERFLY=9
firefly=7
fIREFLY=7
FIREFLY=7
amoeba=8
aMOEBA=8
AMOEBA=8
slime=11
sLIME=11
SLIME=11
metalanim=14

0=vOID
16=dIRT
17=mETAL
3=gEM
18=wALL
21=wALLGROW
22=mAGICWALL
10=wallmagicon
5=player
19=exit
6=exitopen
20=rOCK
9=bUTTERFLY
7=fIREFLY
8=aMOEBA
11=sLIME
12=metalanim
24=eRASER
}

interactive_neightbour={
0=true
10=true
11=true
}

interactive_block={
3=true
21=true
22=true
10=true
20=true
9=true
7=true
8=true
11=true
}

block_void=0
block_dirt=16
block_metal=17
block_gem=3
block_wall=18
block_wallgrow=21
block_wallmagic=22
block_wallmagicon=10
block_player=5
block_exit=19
block_exitopen=6
block_rock=20 
block_butterfly=9
block_firefly=7
block_amoeba=8
block_slime=11
block_metalanim=12
block_walleraser=24

move={
0,-1
1,0
0,1
-1,0
}
moveup=2,3,4,1
movedown=4,1,2,3

colors={
{
4=4
5=5
6=6
}
{
4=4
5=140
6=12
}
{
4=132
5=4
6=09
}
{
4=4
5=3
6=11
}
{
4=5
5=2
6=8
}
{
4=132
5=134
6=15
}
{
4=4
5=141
6=14
}

}

header={
name,cave
size,40,22
{
intermission
false
}
{
loopx
false
}
{
loopy
false
}
needed,1,1,1,1,1
time,120,110,100,90,80
magicwalltime,30
amoeba_time,60
amoeba_fast,64
amoeba_slow,8
amoeba_limit,200
slime_permeability,32
player,1,0,2,0
seed,0,1,2,3,4
random,0,0,0,0,0,0,0,0
}
mapheadersize=14

lines={
point=1,0,0,0
line=2,0,0,0,0,0
rect=3,0,0,0,0,0,0
box=4,0,0,0,0,0
raster=5,0,0,0,0,0,0,0
add=6,0,0,0,0
rect1=7,0,0,0,0,0
1=point
2=line
3=rect
4=box
5=raster
6=add
7=rect1
}




blackpal=0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


TRUE=true
FALSE=false
_rnd1=0
_rnd2=0
gamemode=""
deltaframe=8

camcenterdelta={
-1=1
0=.85
1=1
}

]]


function carryflag(x) 
 return x&0xff,x > 0xff and 1 or 0 
end

function random(d)
 local tmp1,tmp2,result,carry=(_rnd1&0x01)*0x80,(_rnd2>>1)&0x7f,carryflag(_rnd2 + (_rnd2&0x01)*0x80)
 _rnd2,carry=carryflag(result+carry+0x13)
 result,carry=carryflag(_rnd1+carry+tmp1) 
 _rnd1=carryflag(result+carry+tmp2)
 d=d or 256
 return tonum(d) and _rnd1%(d) or d[_rnd1%#d+1]
end

function prefix(x,l)
 x=tostr(x)
 while #x<l do x="0"..x end
 return x
end

function change_gamemode(mode)
 call("exit_"..gamemode)
 gamemode=mode
 call("init_"..gamemode)
end

function _slvl(t)
 return not t and 0 or tonum(t) and t or t[mid(demo and 1 or level,1,#t)] 
end

function _init()
 global[[
 
poke(0x5f58,0x81)
memcpy(0x5600,0x2fc0,0x40)
memcpy(0x5709,0x2cce,0x2f2)

poke(0x5f56,0xa0)
poke(0x5f36,0x10)
poke(0x5f5a,@block_metal)
pal(14,140,1)
pal(14,0,1)
caves_load()
call(caves_subtitle)
sound={}
_adr=0x80c3.8
 ]] 
 for i=0x2694,0x2ccd do
  for b=0,7 do
   write( (@i & (1<<b) !=0) and 7 or 0)
  end
 end

 change_gamemode(editor and "editorstart" or "title") 

end


function _update60()

 _frame+=1

 phase=_frame%deltaframe

 memcpy(0x000,anim[_frame\8%#anim+1],0x0200)

 call("update_"..gamemode) 

 if (sound.gem) poke(0x3244,rnd(gemsound)) 
 
 for k,v in pairs(sfxnb) do
  if (sound[k]) sfx(v,-2) sfx(v) sound[k]=false
 end
 

 
end

function _draw()
 cls()
 call("draw_"..gamemode) 
 camera()
 if (debuginfo) global[[printoc(@debuginfo,64,120,7)]]
end

-->8
--game

function loopxy(x,y)
 if (loopx) x+=x<1 and gamew2 or x>gamew2 and -gamew2 or 0
 if (loopy) y+=y<1 and gameh2 or y>gameh2 and -gameh2 or 0 
 return x,y
end


function draw_cave()

 local x,y,w,h=0,0,gamewidth,gameheight
 if (loopx) x,w=1,gamew2
 if (loopy) y,h=1,gameh2

 if (w-x<=16) camx=(16-w+x)*8
 if (h-y<=16) camy=(16-h+y)*8 
 
 local xs,xe,ys,ye=camx<=x*8 and -1 or 0,camx>=w*8-128 and 1 or 0,camy<=y*8 and -1 or 0,camy>=h*8-128 and 1 or 0
 
 
 for dx=xs,xe do
  for dy=ys,ye do
   camera(flr(camx+.5)-dx*w*8,flr(camy+.5)-dy*h*8)
   map(x,y,x*8,y*8,w,h,flag_visible)
   sprite_draw()
  end
 end
 
 camera()
end


function sprite_handle()
 for a in all(sprites_anim) do
  a.sframe+=1
  if a.sframe%2==0 then
   a.phase+=1
   if (a.phase>#a.anim) del(sprites_anim,a)
  end
 end

 local d=8/deltaframe
 step=ceil(phase*d)-ceil((phase-1)*d)

 ply_x,
 ply_y
 =
 mid(ply_x,ply_x2,ply_x+sgn(ply_x2-ply_x)*step),
 mid(ply_y,ply_y2,ply_y+sgn(ply_y2-ply_y)*step)

 for g in all(followgems) do
  g[2]+=sgn(ply_x+1-g[2])
  g[3]+=sgn(ply_y+1-g[3])
  if (g[2]==ply_x+1 and g[3]==ply_y+1) del(followgems,g)
 end

 for s in all(sprites) do
  s.x1,
  s.y1
  =
  mid(s.x1,s.x2,s.x1+sgn(s.x2-s.x1)*step),
  mid(s.y1,s.y2,s.y1+sgn(s.y2-s.y1)*step)

  if get(s.x2\8,s.y2\8)&0x7f!=s.typ then
   del(sprites,s)
  elseif s.x1==s.x2 and s.y1==s.y2 then
   del(sprites,s) 
   local x,y=loopxy(s.x1\8,s.y1\8)
   mset(x,y,s.typ)
  end
 end

end

function sprite_draw()

 for a in all(sprites) do
  spr(a.anim and a.anim[_frame\2%#a.anim+1] or a.typ,a.x1,a.y1,1,1,a.fx,a.fy)
 end

 if not (ply_finished and ply_x==ply_x2 and ply_y==ply_y2) and not ply_dead then
  spr(ply_anim[_frame\2%#ply_anim+1],ply_x,ply_y,1,1,ply_fx,ply_fy)
  for g in all(followgems) do
   spr(unpack(g))
  end
 elseif (ply_finished and ply_x==ply_x2 and ply_y==ply_y2) then
  spr(block_exit,ply_x,ply_y)
 end

 for a in all(sprites_anim) do
  spr(a.anim[a.phase],a.x,a.y)
 end
end

function sprite_move(x1,y1,x2,y2,md)
 typ=get(x1,y1)&0x7f
 set(x1,y1)
 set(x2,y2,typ|0x80,md)
 return add(sprites,{x1=x1*8,y1=y1*8,x2=x2*8,y2=y2*8,typ=typ})
end

function sprite_anim(x,y,anim)
 return add(sprites_anim,{x=x,y=y,anim=anim,phase=1,sframe=0})
end

function limit_camera(midx,midy)
 return loopx and midx or mid(0,gamewidth*8-128,midx), loopy and midy or mid(0,gameheight*8-128,midy)
end
function handle_camera()
 deltacamx,deltacamy=mid(deltacamx+cx,-48,48)*camcenterdelta[cx],mid(deltacamy+cy,-48,48)*camcenterdelta[cy]
 
 camx,camy=limit_camera(ply_x-60+deltacamx,ply_y-60+deltacamy)
end

function mdget(x,y)
 x,y=loopxy(x,y)
 return mapdata[x.."x"..y] or 0
end
function mdset(x,y,d)
 x,y=loopxy(x,y)
 mapdata[x.."x"..y]=d
end

function get(x,y)
 x,y=loopxy(x,y)
 local m=mget(x,y)
 return m,mapdata[x.."x"..y] or 0
end
function set(x,y,sp,d)
 x,y=loopxy(x,y)
 mset(x,y,sp)
 mapdata[x.."x"..y]=d 
end

function player_handle()
 

 if record then
  if (pause and btn(🅾️)) pause=false

 elseif demo then
  if (btnp(❎)) ply_dead="demo quit"

 end

 dx=btn(⬅️) and -1 or btn(➡️) and 1 or 0
 dy=btn(⬆️) and -1 or btn(⬇️) and 1 or 0

 
 if phase!=0 then
  if dx!=0 or dy!=0 then
   if (btn(❎) and btn❎!=old❎) forcedx,forcedy=dx,dy
   if (dx!=olddx or dy!=olddy)suggestx,suggesty=dx,dy
  end
  return false
 end
 
 ply_x,ply_y=loopxy(ply_x\8,ply_y\8)
 
 ply_x*=8
 ply_y*=8
 global[[
ply_x2=ply_x
ply_y2=ply_y
]]
 
 ply_x2,ply_y2=ply_x,ply_y
 
 if (ply_finished or ply_dead) return false

 if demo then
  dx,dy,btn❎=0,0,false
  if #auto>0 then

   local t=auto[1][1]
   dx=t=="l" and -1 or t=="r" and 1 or 0
   dy=t=="u" and -1 or t=="d" and 1 or 0
   btn❎= auto[1][2]==0

   auto[1][2]-=1
   if (auto[1][2]<=0) deli(auto,1)
   


  else
   wait-=1
   if (wait<=0) ply_dead="demo quit"
  end

 else

  pause=false
  if forcedx or forcedy then
   dx,dy,btn❎,forcedx,forcedy=forcedx,forcedy,true
  else
   if (dx==0 and dy==0 and (suggestx or suggesty)) dx,dy=suggestx,suggesty
   btn❎=btn(❎)
  end
  suggestx,suggesty=nil  

  if dx!=0 and dy!=0 then
   if olddy!=0 then
    local t=get(ply_x\8+dx,ply_y\8)
   if (allowed_move[t]) dy=0 else dx=0   
   else
    local t=get(ply_x\8,ply_y\8+dy)
   if (allowed_move[t]) dx=0 else dy=0   
   end
  end

  if record then
   if (dx==0 and dy==0) if (not btn(🅾️)) pause=true return false

   if (btn❎ and old❎) pause=true return false

   local t=dx==1 and "r" or dx==-1 and "l" or dy==1 and "d" or dy==-1 and "u" or "s"
   local a=auto[#auto]
   
   if btn❎ then
    add(auto,{t,0})
   elseif #auto==0 or a[1]!=t or a[2]==0 or a[2]>=demomaxstep then
    add(auto,{t,1})
   else
    auto[#auto][2]+=1
   end

  else

   cx,cy=0,0
   if (btn(🅾️)) dx,dy,cx,cy=0,0,dx,dy
  end

 end


 if dx!=0 then
  ply_anim,ply_fx=anim.plyright, dx==-1

 elseif dy!=0 then
  ply_anim,ply_fx=dy<0 and anim.plyup or anim.plydown, false

 else
  ply_boring+=1
  ply_anim,ply_fx=ply_boring > 120 and anim.plyboring or anim.plystand, false
 end


 if dx!=0 or dy!=0 then
  ply_boring=0
  local x,y=ply_x\8,ply_y\8
  local xx,yy=x+dx,y+dy

  local typ,data=get(xx,yy)

  if typ==block_exitopen then
   ply_x2,ply_y2=xx*8,yy*8
   ply_push,ply_finished,sound.exit=0,true,true
   set(x,y,block_void)

  elseif allowed_move[typ] then
   if (typ==block_gem) ply_gems+=1 sound.collect=true add(followgems,{15,xx*8+1,yy*8+1})
   if btn❎ then
    set(xx,yy,block_void)
   else
    ply_x2,ply_y2,sound.steps=xx*8,yy*8,true
    set(xx,yy,block_player)
    set(x,y,block_void)
   end
   
   if (typ==block_dirt) sprite_anim(xx*8,yy*8,dx==-1 and anim.dirtright or dx==1 and anim.dirtleft or dy==-1 and anim.dirtup or anim.dirtdown)
   ply_push=0


  elseif dx!=0 then
   ply_anim=anim.plymove
  end

  if is_moveable[typ] and dx!=0 then
   ply_push+=1

   if ply_push>=2 and get(xx+dx,yy)==block_void then
    sprite_move(xx,yy,xx+dx,yy,1)
    if btn❎ then
     set(xx,yy,block_void)
    else
     ply_x2,ply_y2,sound.steps=xx*8,yy*8,true
     set(xx,yy,block_player)
     set(x,y,block_void)
    end
    ply_push=0
   end
  end
  
 else
  ply_push=0
 end
 
 olddx,olddy,old❎=dx,dy, (dx!=0 or dy!=0) and btn❎


end

function explode(x,y,bl)
 sound.explosion=true
 for dy=y-1,y+1 do
  for dx=x-1,x+1 do
   local typ,data=get(dx,dy)

   if not is_indestructible[typ] then
    sprite_anim(dx*8,dy*8,anim.explosion)
    set(dx,dy,bl)

    if (typ==block_player) ply_dead="exploded"
   end

  end
 end
end

function cave_gamelogic()
 if (phase>7) return false
 if phase>=1 and phase<=4 then
  
  if (phase==1)check,amoeba_free={},{}
  
  for y=1,gameh2 do
   for x=1,gamew2 do
    local xx,yy=loopxy(x+move[phase][1],y+move[phase][2])
    local t,d=mget(x,y),mapdata[x.."x"..y] or 0
    local tt=mget(xx,yy)&0x7f
    

    if (amoeba_move[tt] and t==block_amoeba) add(amoeba_free,{xx,yy})
    if ( d!=0 or t&0x80!=0 or (interactive_neightbour[tt] and interactive_block[t]) ) check[x.."x"..y]=true
    
   end    
  end
  
 elseif phase==5 then
global[[
amoeba_count=0
checkxy={}
]]
  swaplines=not swaplines  
  for y=gameh1,0,-1 do
   
   local xa,xb,xc=0,gamew1,1
   if (y%2==(swaplines and 1 or 0))  xa,xb,xc=xb,xa,-1 
   for x=xa,xb,xc do
    if (mget(x,y)&0x7f==block_amoeba) amoeba_count+=1
    
    local t=replace[mget(x,y)]
    if (t) mset(x,y,t)
    if (check[x.."x"..y]) add(checkxy,{x,y})
   end
  end
  replace={}
  
  if amoeba_count>0 then
   loopsound(sfx_amoeba)
   
   if #amoeba_free<=0 then
global[[
replace.8=@block_gem
stopsound(@sfx_amoeba)
]]
   elseif amoeba_count>=amoeba_limit then
global[[
replace.8=@block_rock
stopsound(sfx_amoeba)
]]
   elseif random() <=  (amoeba_time<=0 and amoeba_fast or amoeba_slow) or ply_boring > 150 then
global[[
amoeba_rnd=random(@amoeba_free)
set(@amoeba_rnd.1,@amoeba_rnd.2,@block_amoeba)
]]
   end
  else
   stopsound(sfx_amoeba)
  end
  
  
 elseif phase==0 then
  enemies={}
  for xy in all(checkxy) do
   local x,y=unpack(xy)
   local typ,data=get(x,y)

   if typ&0x80==0 and is_fallable[typ] then
    local typ⬇️=get(x,y+1)
    local inmove=typ⬇️&0x80!=0
    typ⬇️&=0x7f

    if typ⬇️==block_void then
     sprite_move(x,y,x,y+1,1)

    elseif typ⬇️==block_player then
     if (data==1) explode(x,y+1) ply_dead="smashed"
     
    elseif typ⬇️==block_firefly then
     if (data==1) explode(x,y+1)

    elseif typ⬇️==block_butterfly then
     if (data==1) explode(x,y+1,block_gem)

    elseif typ⬇️==block_wallmagicon then
     if get(x,y+2)==block_void then
      set(x,y,typ==block_gem and block_rock or block_gem)
      local tab=sprite_move(x,y,x,y+2,1)
      tab.anim=anim.wallmagic
     end
     
    elseif typ⬇️==block_walleraser then
     sprite_anim(x*8,y*8,anim.explosion)
     set(x,y,block_void)
     sound.burning=true
     
    elseif typ⬇️==block_slime then
     if (get(x,y+2)==block_void and random()<slime_permeability) sprite_move(x,y,x,y+2,1)

    elseif typ⬇️==block_wallmagic and data==1 then
global[[      
wallmagic_active=true
replace.22=@block_wallmagicon
loopsound(@sfx_wallmagic)
]]
    elseif not inmove and is_glide[typ⬇️] then
     if (data==1) sound[typ==block_gem and "gem" or "rock"]=true
     local d=random(2)==1 and 1 or -1
     for dx=x-d,x+d,2*d do
      if (get(dx,y)==block_void and get(dx,y+1)==block_void and not is_fallable[get(dx,y-1)]) sprite_move(x,y,dx,y,1) break
     end
     mdset(x,y)

    else
     if data!=0 then
      sound[typ==block_gem and "gem" or "rock"]=true
      mdset(x,y)        
     end
    end
   end

   if (is_enemy[typ]) add(enemies,{x,y,typ,flag,data})
   
   if typ==block_wallgrow then
    for i=-1,1,2 do
     if (get(x+i,y)==block_void) set(x+i,y,block_wallgrow)
    end
   end

   
  end
  
  for enb=#enemies,1,-1 do
   local x,y,typ,flag,data=unpack(enemies[enb])
   if mget(x,y)==typ then
    if typ!=block_butterfly then
     cc,cl=moveup,movedown
    else
     cc,cl=movedown,moveup
    end

    local ok,catched=true,true
    for m in all(move) do
     local typm,datam=get(x+m[1],y+m[2])
     if (typm==block_void) catched=false
     if (enemy_touchexplode[typm]) or
     (m[2]==-1 and is_fallable[typm] and datam==1) then
      explode(x,y,typ==block_butterfly and block_gem)
      if (typm==block_player) ply_dead="caught"
      ok=false
      break
     end
    end

    if ok then
     if catched then
      mdset(x,y,0x20+(data&0xf))       
      
     elseif data>=0x10 then
      mdset(x,y,data-0x10)
     else
      local dside=cl[data]

      local xx,yy=x+move[dside][1],y+move[dside][2]
      local typt,datat=get(xx,yy)
      if typt==block_void then
       sprite_move(x,y,xx,yy,dside)
      elseif not is_fallable[typt] or datat==0 then
       xx,yy=x+move[data][1],y+move[data][2]
       typt,datat=get(xx,yy)
       if typt==block_void then
        sprite_move(x,y,xx,yy,data)
       elseif not is_fallable[typt] or datat==0 then
        dside=cc[data]
        xx,yy=x+move[dside][1],y+move[dside][2]
        typt,datat=get(xx,yy)
        if typt==block_void then
         sprite_move(x,y,xx,yy,dside)
        elseif not is_fallable[typt] or datat==0 then
         mdset(x,y,dside)
        end
       end
      end
     end     
    end    
    
   end
  end
  
  
 end
end

function loopsound(x)
 if (not loopsounddata[x]) loopsounddata[x]=true sfx(x)
end
function stopsound(x)
 loopsounddata[x]=false 
 sfx(x,-2)
end

function init_game()
 global[[
deltacamx=0
deltacamy=0
wait=60
blink=0
pause=false
cx=0
cy=0
pause=false
forcedx=false
forcedy=false
suggestx=false
suggesty=false
olddx=false
olddy=false
old❎=false
sprite_anim(@ply_x,@ply_y,@anim.explosion)
ply_anim=@anim.plystand
sound.spawn=true
]]
 menuitem(1,"give up",function() explode(ply_x\8,ply_y\8) ply_dead="oh no!" end)
end

function exit_game()
 global[[
stopsound(@sfx_amoeba)
stopsound(@sfx_wallmagic)
menuitem(1)
menuitem(2)
debuginfo=@NIL
]]
end

function update_game()

 player_handle()

 if pause and phase==0 then
  _frame-=1
  return false

 else
  if phase==0 then
   timersub+=8
   if timersub>=60 then
    timersub-=60
    
    if wallmagic_active then
     wallmagic_time-=1
     if wallmagic_time<0 then
      global[[
stopsound(@sfx_wallmagic)
replace.10=@block_walleraser
wallmagic_active=false
]]
     end
    end
    
    if (amoeba_time>0) amoeba_time-=1
    
    if timer>0 and not ply_finished and not ply_dead then

     timer-=1
     if (timer<=10 and timer>0) sound[timer%2==0 and "dong" or "ding"]=true
     
     if (timer<=0) ply_dead="time out" sound.timeout=true
    end
   end
  end
  

  

  if ply_gems>=neededgems and exitopen==false then
   global[[
exitopen=true
replace.19=@block_exitopen
sound.exitopen=true
]]
  end

  

  global[[
sprite_handle()
handle_camera()
cave_gamelogic()
]]
 end

 if ply_finished or ply_dead then
  if record and #auto>0 then
   
   global[[
cave.demo=@auto
debuginfo=@NIL
auto={}
]]
  end
 end


 if ply_dead or ply_finished then
  wait-=1
  if (wait<=0) change_gamemode "caveexit"
 end

end

function draw_game()
 camera(flr(camx+.5),flr(camy+.5))

 if exitopen and cave_rad<cave_maxrad then
  cave_rad+=2
  for i=0,-2,-1 do
   circ(exitx,exity,cave_rad-i,7-i)
  end
 end

draw_gamestr="◆"..prefix(ply_gems,3)..
 "/"..prefix(neededgems,3)..
 " ⧗"..prefix(timer,3)..
 " ♥"..prefix(ply_lives,2)

 global[[
draw_cave()
camera()
printoc(@draw_gamestr,64,0,9)
]]
global"printo(\015◆,27,1,8)\nprinto(/,46,0,8)\nprinto(\015⧗,64,1,8)\nprinto(\015♥,85,1,8)"

 if (editor) debuginfo=amoeba_time.." "..wallmagic_time
 
 if demo then
  blink+=1
  if (blink\120%2==1) global"printoc(pRESS \015\|h❎,64,65,7)"
 end

end

function init_gameloop()
 
 if ply_finished or (ply_dead and cave.intermission) then 
  currentcave+=1
  if (currentcave>#caves) level+=1 global "level=min(@level,5)\ncurrentcave=1"
 end

 change_gamemode(ply_lives<=0 and "title" or "caveintro")
end

function init_gamestart()
 global[[
ply_lives=3
ply_score=0
ply_finished=false
ply_dead=false
bonuslivescore=@livesforscore
change_gamemode(gameloop)
 ]]  
end

-->8
--inextro

function init_caveintro()
 prepare_cave()
 
 for y=0,127,8 do
  for x=0,127,8 do
   add(mask,{block_metalanim,x,y})
  end
 end


 
 
 loopsound(sfx_trans)

end
function exit_caveintro()
 stopsound(sfx_trans)
end
exit_caveexit=exit_caveintro

function update_caveintro()
 del(mask,rnd(mask))
 del(mask,rnd(mask))
 if (#mask<=0) stopsound(sfx_trans)

 if (phase==0) wait-=1 
 if (wait < -3) change_gamemode "game"

 sprite_handle()

 cave_gamelogic()

end

function draw_caveintro()
 draw_cave()
 
 camera()
 for e in all(mask) do
  spr(unpack(e))
 end

 if wait>0 then
  
  printoc(cave.subname,64,50,9)
  printbigc(cave.name,64,58,10)
 end

end


function init_caveexit()
 global[[
followgems={}
bonuslives=0
wait=20
bonus=0
newhiscore=false
]]
 
 mask,mask2={},{}
 for x=0,15 do
  for y=0,15 do
   add(mask2,{block_metalanim,x*8,y*8})
  end
 end
 
 loopsound(sfx_trans)

 if ply_finished and cave.intermission then
  ply_lives+=1 
  sound.oneup=true
  bonuslives+=1
 elseif ply_dead and not cave.intermission then
  ply_lives-=1
 end
 

end

function update_caveexit()

 if ply_finished then
  if demo then
   if #mask2<=0 then
    wait-=1
    if (wait<=0) change_gamemode "title" return false
   end
  elseif wait>0 then
   if (#mask2<=0) wait-=1
  else
   repeat
    if ply_gems>0 then
     ply_score+=ply_gems>neededgems and 10 or 5
     bonus+=ply_gems>neededgems and 10 or 5
     ply_gems-=1
     sound.bonus=true
    elseif timer>0 then
     ply_score+=1
     bonus+=1
     sound.bonus=true
     timer-=1
    elseif bonus>hiscores[level][currentcave] then
     newhiscore=true
     hiscores[level][currentcave]=bonus
     save_hiscores()
     sound.highscore=true
     
    elseif btnp(❎) then
     change_gamemode "gameloop" 
     return false
    end
    
    

    if ply_score>=bonuslivescore then
     bonuslivescore+=livesforscore
     ply_lives+=1
     bonuslives+=1
     sound.oneup=true
    end

   until not btnp(❎)
  end
 end


 for i=0,4 do
  add(mask,del(mask2,rnd(mask2))) 
 end
 if (#mask2<=0) stopsound(sfx_trans)


 if ply_dead and #mask2<=0 then
  if wait>0 then
   wait-=1
  elseif ply_dead and ply_lives<=0 and ply_score>totalscore[10] and not demo then
   change_gamemode"newtotalscore"
   
  elseif ply_lives>0 or btnp(❎) or demo then
   
   change_gamemode(demo and "title" or "gameloop") 
   return false
  end
 end


end

function draw_caveexit()
 draw_cave()

 camera()
 for m in all(mask) do

  spr(unpack(m))
 end
 doblink=false

 if not demo then 
  if ply_finished then
   printbigc("gEMS: "..prefix(ply_gems,3),64,34,ply_gems>0 and 10 or 9)
   printbigc("tIME: "..prefix(timer,3),64,48,(ply_gems==0 and timer>0) and 10 or 9)
   printbigc("sCORE: "..ply_score,64,62,(ply_gems==0 and timer==0) and 10 or 9)  
   printoc("bONUS: "..bonus,64,76,9)
   if (ply_gems==0 and timer==0) doblink=true
   
  end

  if (ply_dead and wait>10) printbigc(ply_dead,64,58,10)
  if ply_dead and wait<=0 and ply_lives<=0 then
   global[[
printbigc(gAME oVER,64,52,8)
printoc(@ply_score,64,66,10)
doblink=true
]]
  end


  if doblink then   
   blink+=1
   if ( blink\120%2==1 ) global"printoc(pRESS \015\|h❎,64,86,7)"

  end
  
  if bonuslives>0 then
   x=64-4*bonuslives
   for i=1,bonuslives do
    pal(blackpal,0)
    for d=-1,1,2 do
     spr(69,x+d,110)    
     spr(69,x,110+d)
    end
    pal(0)
    spr(69,x,110)
    x+=8
   end
  end
  
  if newhiscore then
   printoc("nEW cAVE sCORE!",64,120,10)
  end
  
 end
end

function init_newtotalscore()
 name=""
 ch=1
 sound.highscore=true
end

function update_newtotalscore()
 if (btnp(⬆️) or btnp(➡️)) ch+=1
 if (btnp(⬇️) or btnp(⬅️)) ch-=1
 ch=mid(1,#chars,ch)
 if btnp(❎) then
  if #name==3 then 
   -- insert
   i=10
   while i>1 and ply_score>totalscore[i-1] do
    i-=1
   end
   add(totalscore,ply_score,i)
   add(totalname,name,i)
   save_hiscores()
   change_gamemode "title"
  else
   name..=chars[ch]
  end
 end
 if (btnp(🅾️)) name=sub(name,1,#name-1)
end


function draw_newtotalscore()
 draw_cave()

 camera()
 for m in all(mask) do
  spr(unpack(m))
 end

 printbigc("nEW hIGH sCORE",64,32,9)
 printbigc(ply_score,64,50,10)
 printoc("eNTER YOUR NAME:",64,66,6)
 x=printbigc(name,60,76,6) 
 if #name>=3 then  
  printo("eND",x+2,80,7)
 else
  printbigc(chars[ch],-x,76,7) 
 end

end
-->8
--cave
function cave_add(typ,typ2,dx,dy)
if (dx>=0x80) dx|=0xff00
if (dy>=0x80) dy|=0xff00
 for y=1,gameh2 do
   for x=1,gamew2 do
     if (mget(x,y)==block[typ]) mset(x+dx,y+dy,block[typ2])
   end
 end
end


function cave_line(typ,x1,y1,x2,y2)
 local dx,dy=x2-x1,y2-y1
 local d=max(abs(dx),abs(dy))
 dx/=d
 dy/=d
 for i=0,d do
  mset(x1+dx*i+.5,y1+dy*i+.5,block[typ])
 end
end

function cave_raster(typ,x,y,w,h,dx,dy)
 local xx,yy
 for yy=y,y+(h-1)*dy,dy do
  for xx=x,x+(w-1)*dx,dx do
   mset(xx,yy,block[typ])
  end
 end
end

function cave_point(typ,x,y)
 mset(x,y,block[typ])
end

function cave_rect(typ,ftyp,x1,y1,x2,y2)
 for y=y1,y2 do
  for x=x1,x2 do
   local f=(x==x1 or x==x2 or y==y1 or y==y2) and typ or ftyp
   if(f) mset(x,y,block[f])    
  end
 end
end
function cave_rect1(typ,...) cave_rect(typ,typ,...) end

function cave_box(typ,...)
 cave_rect(typ,nil,...)
end

function _cave(what,...)
 call("cave_"..what,...)
end

function xy(i,...)
 return i%gamew2 +1,i\gamew2+1,...
end

function cave_render()
 global[[
_rnd2=_slvl(@cave.seed)
_rnd1=0
gamewidth=@cave.size.1
gameheight=@cave.size.2
mapdata={}
memset(0xa000,@block_metal,0x5fff)
]]
gamew1,gameh1,gamew2,gameh2=gamewidth-1,gameheight-1,gamewidth-2,gameheight-2


 if cave.ismap then
  local last,i,_rm_index=block_void,0,0
  function _readmap()
   _rm_index+=1
   return cave.map[_rm_index] or 0
  end
  
  while i<gamew2*gameh2 do
   c,fn=_readmap()
   
   if c==flag_last then
    fn=function() return last end
   elseif c==flag_above then
    fn=function() return mget(xy(i-gamew2)) end
   elseif c==flag_dirt then
    fn=function() return block_dirt end
   end
   
   if fn then
    for a=1,_readmap()+3 do   
     mset(xy( i,fn() ))
     i+=1
    end
   else
    last=id2block[c]
    mset(xy(i,last))
    i+=1
   end  
  end
  
 else
  for y=1,gameh2 do 
   random()
   for x=1,gamew2 do   
    local r,typ=random(256),block_dirt
    for e in all(tsplit(cave.random,2)) do
     if (r<e[2]) typ=block[e[1]]
    end
    mset(x,y,typ)
   end
   random()
  end
  foreach(cave,function (t) _cave(unpack(t)) end)
 end

 cave_box("metal",0,0,gamew1,gameh1)
 global[[
mset(@cave.player.1,@cave.player.2,@block_player)
mset(@cave.player.3,@cave.player.4,@block_exit)
]]
end

function prepare_cave()
cave=caves[currentcave]

 global[[
swaplines=true
amoeba_count=0
totalgems=0
wallmagic_active=false
exitopen=false
sprites={}
sprites_anim={}
mapdata={}
replace={}
check={}
checkxy={}
loopsounddata={}
camx=0
camy=0
followgems={}

_frame=-1

mask={}
 
ply_dead=false
ply_finished=false

ply_push=0
ply_gems=0
ply_anim=@anim.plystand
ply_boring=0
ply_fx=false
ply_fy=false

wait=15 
deltamask=2

auto={}

cave_maxrad=500
cave_rad=4

slime_permeability=@cave.slime_permeability
cave_render()
ply_x=@cave.player.1
ply_y=@cave.player.2
exitx=@cave.player.3
exity=@cave.player.4
ply_anim=@anim.inbox
amoeba_fast=@cave.amoeba_fast
amoeba_slow=@cave.amoeba_slow
amoeba_limit=@cave.amoeba_limit

timer=_slvl(@cave.time)
timersub=0
amoeba_time=_slvl(@cave.amoeba_time)
wallmagic_time=_slvl(@cave.magicwalltime)

loopx=@cave.loopx
loopy=@cave.loopy
]]
  
 

 exitx*=8
 exity*=8
 ply_x*=8
 ply_y*=8
 

 
 for y=0,gameh1 do
  for x=0,gamew1 do
   local t=mget(x,y)
   if t==block_gem then
    totalgems+=1
    
   elseif is_enemy[t] then
    local cc= t!=block_butterfly and moveup or movedown
    
    mdset(x,y,1)
    for i=1,4 do
     local a=mget(x+move[i][1],y+move[i][2])
     if (not enemy_notattach[a]) mdset(x,y,cc[i])
    end   
    
   end
  end
 end

 neededgems=_slvl(cave.needed)
 
 camx,camy=limit_camera(ply_x-60,ply_y-60)
 
global[[
ply_x2=@ply_x
ply_y2=@ply_y
]] 
 
 
 pal(colors[currentcave%#colors+1],1)
 
 if not record then
  for x in all(cave.demo) do
   add(auto,{unpack(x)})
  end
 end
end

function addpeek()
 --if(_adr>=0x3000)return 0
 _adr+=1
 return peek(_adr-1)
end

function read()
 _adr+=0.5
 return _adr%1!=0 and @_adr\16 or @_adr&15
end

function write(b)
 _adr+=0.5
 poke(_adr, _adr%1!=0 and @_adr|b*16 or b)
end


function cave_read()
 local i,n,v,prefix,prefix2,index=0
 cave={}

 local flag=addpeek()
 for f,v in pairs(cave_flags) do
   cave[f]=flag&v!=0
 end
 
 
 repeat  
  i+=1
  if i<=#header then
   n=header[i]  
   v,index,prefix,prefix2=n[1],2
  else
   local xx=addpeek()
   local x=xx\16
   prefix2=id2block[xx%16]
   if (x==0) break
   v,prefix=i-#header,lines[x]
   n,index=lines[prefix],3
  end
  
  local typ=type(n[index])  
  
  if typ=="string" then
   cave[v]=""
   repeat
    local ch=addpeek()
    cave[v]..=chr(ch&0x7f)   
   until ch>=0x80 or ch==0
  elseif typ!="boolean" then
   if #n==index then
    cave[v]= addpeek()

   else
    cave[v]={prefix,prefix2}
    for i=index,#n do
     add(cave[v],addpeek())
    end
    
    local a,b,d
    if (prefix) a,b,d=2,(prefix=="rect" or prefix=="add") and 3 or 2,1
    if (v=="random") a,b,d=1,7,2
    if (a) for i=a,b,d do cave[v][i]=block[cave[v][i]] end
   end
  end 
  
 until cave.ismap 
 
 if cave.ismap then
  _adr-=0.5
  cave.map={}
  local i,s=0,0
  while i<(cave.size[1]-2)*(cave.size[2]-2) do
   local c=read()
   s+=c
  if (c>=flag_first) add(cave.map,c) c=read() i+=c+3 else i+=1
   add(cave.map,c)
  end
  s%=255
  cave.seed={s,s,s,s,s}
  _adr=ceil(_adr)
 end

 cave.demo={}
 repeat
  local c=addpeek()
  if (c==0) break
  add(cave.demo,{demomove[c%demodiv],c\demodiv})
 until false


end

function caves_load()
global[[
caves={}
_adr=0x1000
]]
 while @_adr!=0 do
  cave_read()
  add(caves,cave)
 end 
end


-->8
--title


global[[
chars=abcdefghijklmnopqrstuvwxyz_.0123456789


recolor={
0=0
1=5
2=6
3=7
}

infotext={
{
@anim.plyboring
rOCKFORD
}
{
@block_dirt
dIRT
}
{
@block_rock
rOCK
}
{
@block_gem
gEM
}
{
@block_wall
wALL
}
{
@block_metal
mETAL wALL
}
{
@block_wallgrow
gROWING wALL
}
{
@block_wallmagic
mAGIC wALL
}
{
@block_exit
cLOSED eXIT
}
{
@block_exitopen
oPEN eXIT
}
{
@block_butterfly
bUTTERFLY
}
{
@block_firefly
fIREFLY
}
{
@block_amoeba
aMOEBA
}
{
@block_slime
sLIME
}
{
@block_walleraser
eRASER wALL
}
}

credits={
rOCKFALL
gpi
.
bOULDER dASH i & ii
pETER lIEPA
cHRIS gRAY
.
tITEL-mUSIC "dEMENTED mARIO"
gRUBER
.
cAVE dESIGN
@author
}



_adr=0x42ff.8
]]


if (dget(63)!=0) reload (0x1000,0x1000,0x2000,"rockfall-editor.p8") cstore() dset(63,0)

for d=0x223d,0x2693 do
 for i=0,6,2 do
  write(recolor[@d>>i & 0x3])
 end
end

function load_hiscores()
 local adr=0x5e00
 hiscores,totalscore,totalname={},{},{}
 for l=1,5 do
  hiscores[l],totalscore[l],totalname[l]={},{},{}
  for c=1,20 do
   hiscores[l][c]=%adr
   adr+=2
  end
  
 end
 for i=1,10 do
  if %adr==0 then    
   totalscore[i]=4400-400*i
   totalname[i]="gpi"
   adr+=5
  else
   totalscore[i]=%adr
   totalname[i]=chr(peek(adr+2,3))
   adr+=5
  end
  
 end
  --5EC8 free
  --5EFC marker levelcopy
 
end
function save_hiscores()
 local adr=0x5e00
 for l=1,5 do
  for c=1,20 do
   poke2(adr,hiscores[l][c])
   adr+=2
  end
 end
 for i=1,10 do
   poke2(adr,totalscore[i])
   poke(adr+2,ord(totalname[i],1,3))
   adr+=5
 end

 
 
end


function menu_add(title,varname,table)
 add(menu,{title,varname,table})

end

function infotext_draw()
 local s=(#infotext+1)\2
 for i,e in pairs(infotext) do
  local x,y=(i-1)\s*64+5,(i-1)%s*11+40
  spr(type(e[1])=="table" and e[1][_frame\2%#e[1]+1] or e[1],x,y)
  printo(tostr(e[2]),x+10,y,7)
 end
end


function menu_draw()
 local y=50
 for nb,e in pairs(menu) do
  local var=_ENV[e[2]]
  if (e[1]) printoc(e[1],64,y,9) y+=8
  local x,t1,t2=e[3][var]
 if (type(x)=="table") t1,t2=unpack(x) else t2=x
  if (t1) printoc(t1,64,y,9) y+=8
  if menu_select==nb then 
   rectfill(0,y,128,y+14,1) 
   printbigc(t2,64,y,menu_select==nb and 7 or 10) 
   y+=16
  else
   printoc(t2,64,y,10) y+=8
  end

 end
end
function menu_do()
 if (btnp(⬆️)) menu_select-=1
 if (btnp(⬇️)) menu_select+=1
 menu_select=limit(menu_select,1,#menu)
 
 local m=menu[menu_select]
 local var=m[2]
 if (btnp(⬅️)) _ENV[var]-=1
 if (btnp(➡️)) _ENV[var]+=1
 _ENV[var]=limit(_ENV[var],1,#m[3])
 
end

function caves_subtitle()
 local i,a,bd=1,97,1
 for cave in all(caves) do
  if cave.intermission then
   cave.subname="iNTERMISSION "..i
   cave.shortname="iNTER. "..i
   i+=1
  else
   cave.subname="cAVE "..chr(a)
   cave.shortname=cave.subname
   a+=1
   if (a==113) a=97 bd+=1
  end
 end
end




function init_title()
 load_hiscores()
 menu={}
 menu_select=1
 local levelnames={}
 for c in all(caves) do
  add(levelnames,{c.subname,c.name})
 end
 menu_add(nil,"startcave",levelnames)
 menu_add("dIFFICULTY","startlevel",split"1,2,3,4,5")
 menu_add("sPEED","speed",split"fAST,nORMAL,mODERATE,sLOW,bORING,sTOP")
 pal(colors[1],1)

 idle=0
 demo=false
 editorwait=0
 
 music(4)
 
 menuitem(1,"show hiscore",function() idle=600 end)
 menuitem(2,"cave score",function() idle=1200 end)
 menuitem(3,"-")
 menuitem(4,"reset hiscore",function() memset(0x5e00,0,256) load_hiscores() end)
 
end

function exit_title()
 for i=1,4 do
   menuitem(i)
 end
 deltaframe=demo and 8 or speedframe[speed]
 music(-1)
end

function update_title()

 menu_do()
 
 if btn()!=0 then
  idle=0
 else
  idle+=1
  if idle>5*600 then
   demo=true
   player={lives=3,score=0}
   currentcave=rnd(#caves)\1+1
   level=1
   change_gamemode "gamestart"
  end
 end
 
 
 if btnp(❎) or btnp(🅾️) then
  demo=btnp(🅾️)
  currentcave=editor or startcave
  level=demo and 1 or startlevel
  change_gamemode "gamestart"
  
 end

end

function draw_title()
 memcpy(0x60c6,0x4300,0x8ae)
 
 if(edition!="") printor(edition.." edition",120,32,7)
 
 if idle<600 then
  menu_draw()
  printoc("cAVE sCORE: "..hiscores[startlevel][startcave],64,121,5)
 
 elseif idle<2*600 then
  printbigc("hIGH sCORE",64,40,9)
  for i=1,10 do
   printoc(totalname[i],52,48+i*7,6)
   printoc(totalscore[i],76,48+i*7,7)
  end
  
 elseif idle<3*600 then
  printoc("cAVE sCORES - dIFFICULTY "..startlevel,64,40,9)
  local total=0
  for i=0,#caves-1 do
   local x,y=i\10*64+4,i%10*7+50
   printoc(caves[i+1].shortname,x+20,y,6)
   total+=hiscores[startlevel][i+1]
   printor(hiscores[startlevel][i+1],x+56,y,hiscores[startlevel][i+1]<=0 and 5 or 7)
   
  end
  printor("tOTAL sCORE:",80,121,6)
  printo(total,85,121,7)
  
 elseif idle<4*600 then
  infotext_draw()
  
 elseif idle<5*600 then
  local y,c=40,9
  for t in all(credits) do
  if (t!=".") printoc(t,64,y,c) y+=8 c=10 else y+=4 c=9
  end
  
  
 end
 

end


--_stat=0
--oldupdate=_update60
--function _update60()
-- oldupdate()
-- if (phase==0) _stat+=1 if (_stat>11) _stat=0
-- if (_stat>10) statmin[phase],statmax[phase]=99,0
-- 
-- statmin[phase],statmax[phase]=min(statmin[phase] or 99,stat(1)),max(statmax[phase] or 0,stat(1))
--end
--olddraw=_draw
--function _draw()
-- olddraw()
-- for i=0,deltaframe-1 do
--  if (statmin[i]) print(i.." "..statmax[i],0,i*7,10)
-- end
--end
--
__gfx__
00f00f000000000000000000000d70000000000000f00f00765e765eaaaaaaaa03bbbb3070000005eddddddddddddddd5555555570007000aaaaa00000500000
00ffff000000f00000000f00009aa7002222222200ffff00eeeeeee7a999999a3bbbabb3670000d6eccddddd111111115ee55ee567066000a999a00006670000
0feffef0000fff000000fff00dd66670000000000feffef05eeeeee6a944449abbabbbbbaa70099aeccccccd11c1111156e556e5aa7aa000a949a0009aaa7000
00ffff0000fffef0000fffef5eeeeee72222222200ffff006eeeeee5a942249abbbbbbbb6667dd66eeeeeeee11111c115555555567066000a999a00006670000
0fcccc00000fff000000fff0dd6666670000000000cccc007eeeeeeea942249abbbbbbbb00075000dddedddd111111115555555570007000aaaaa00000500000
000cc0f0000cc0000000cccf099aaa70222222220f0cc0f0eeeeeee7a944449abbbbbbbb66700dd6dddeccddd112111d5ee55ee5000000000000000000000000
00c0077007cfcc0007cccc0000d667000000000000c00c005eeeeee6a999999a3bbbbbb3a700009accdecccc0d1111d056e556e5000000000000000000000000
07700000070007700700077000057000222222220770077067e567e5aaaaaaaa03bbbb307000000deeeeeeee00dddd0055555555000000000000000000000000
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
__label__
44444445555444444445555444455554444444455554444444455554444555544444444555544444444555544445555444444445555444444445555000000000
44444445555444444445555444455554444444455554444444455554444555544444444555544444444555544445555444444445555444444445555000000000
44444445555444444445555444455554444444455554444444455554444555544444444555544444444555544445555444444445555444444445555000000000
44444445555444444445555444455554444444455554444444455554444555544444444555544444444555544445555444444445555444444445555000000000
6666666666666666666666600000000666666666666777700000000000000000000dddd777700000000000044444444444400004444444444444444444444444
6666666666666666666666600000000666666666666777700000000000000000000dddd777700000000000044444444444400004444444444444444444444444
66666666666666666666666000000006666666666667777000000000000000000dddddd777777000000000044444444444400004444444444444444444444444
66666666666666666666666000000006666666666667777000000000000000000dddddd777777000000000044444444444400004444444444444444444444444
555666666666666666666660000666666666666777777776666000000000000999999aaaa7777770000000000005555444444444444555500004444000055554
55566666666666666666666000066666666666677777777666600000000000099999aaaaa7777770000000000005555444444444444555500004444000055554
5556666666666666666666600006666666666667777777766660000000000999999aaaaaaaa77777700000000005555444444444444555500004444000055554
5556666666666666666666600006666666666667777777766660000000000999999aaaaaaaa77777700000000005555444444444444555500004444000055554
55555555555555555556666555555556666666666667777777766660000dddddddd6666666666777777000044444444444444444444444444445555444444444
55555555555555555556666555555556666666666667777777766660000dddddddd6666666666777777000044444444444444444444444444445555444444444
555555555555555555566665555555566666666666677777777666600dddddddddd6666666666667777770044444444444444444444444444445555444444444
555555555555555555566665555555566666666666677777777666600dddddddddd6666666666667777770044444444444444444444444444445555444444444
00000000000000000000000555566666666777766666666666677775555000000000000000000000077777744444444000055554444555544444444444444440
00000000000000000000000555566666666777766666666666677775555000000000000000000000077777744444444000055554444555544444444444444440
00000000000000000000000555566666666777766666666666677775555000000000000000000000000777744444444000055554444555544444444444444440
00000000000000000000000555566666666777766666666666677775555000000000000000000000000777744444444000055554444555544444444444444440
6660000666666666666666655556666555566666666777766666666dddddddd66666666666666666666777744440000444444444444444444440000444400004
6660000666666666666666655556666555566666666777766666666dddddddd66666666666666666666777744440000444444444444444444440000444400004
6660000666666666666666655556666555566666666777766666666dddddddd66666666666666666677777744440000444444444444444444440000444400004
6660000666666666666666655556666555566666666777766666666dddddddd66666666666666666677777744440000444444444444444444440000444400004
6660000555555556666666655555555666666666666666655556666009999999999aaaaaaaaaaaa7777770044444444555555554444000044444444444444445
6660000555555556666666655555555666666666666666655556666009999999999aaaaaaaaaaaa7777770044444444555555554444000044444444444444445
6660000555555556666666655555555666666666666666655556666000099999999aaaaaaaaaa777777700044444444555555554444000044444444444444445
6660000555555556666666655555555666666666666666655556666000099999999aaaaaaaaaa777777000044444444555555554444000044444444444444445
6660000555555555555555500005555555555556666555555550000000000dddddd6666666677777700000044444444444444444444444444445555444444444
6660000555555555555555500005555555555556666555555550000000000dddddd6666666677777700000044444444444444444444444444445555444444444
666000055555555555555550000555555555555666655555555000000000000dddd6666667777770000000044444444444444444444444444445555444444444
666000055555555555555550000555555555555666655555555000000000000dddd6666667777770000000044444444444444444444444444445555444444444
00000000000000000000000000000005555555555555555000000000000000000555555777777000000000044445555444444445555444444445555444455554
00000000000000000000000000000005555555555555555000000000000000000555555777777000000000044445555444444445555444444445555444455554
00000000000000000000000000000005555555555555555000000000000000000005555777700000000000044445555444444445555444444445555444455554
00000000000000000000000000000005555555555555555000000000000000000005555777700000000000044445555444444445555444444445555444455554
6666666666666666666666644444444444400004444444444444444000000000ff0000000000ff00000000044444444444400004444444444444444444444444
666666666666666666666664444444444440000444444444444444400000000ffff00000000ffff0000000044444444444400004444444444444444444444444
666666666666666666666664444444444440000444444444444444400000000ffff00000000ffff0000000044444444444400004444444444444444444444444
666666666666666666666664444444444440000444444444444444400000000fffff000000fffff0000000044444444444400004444444444444444444444444
555666666666666666666660000555544444444444455550000444400000000ffffffffffffffff0000000000005555444444444444555500004444000055554
55566666666666666666666000055554444444444445555000044440000000ffffffffffffffffff000000000005555444444444444555500004444000055554
5556666666666666666666600005555444444444444555500004444000000ffffffffffffffffffff00000000005555444444444444555500004444000055554
555666666666666666666660000555544444444444455550000444400000ffffffffffffffffffffff0000000005555444444444444555500004444000055554
55555555555555555556666444444444444444444444444444455550000fffff00ffffffffff00fffff000044444444444444444444444444445555444444444
55555555555555555556666444444444444444444444444444455550000ffff0000ffffffff0000ffff000044444444444444444444444444445555444444444
55555555555555555556666444444444444444444444444444455550000ffff0000ffffffff0000ffff000044444444444444444444444444445555444444444
55555555555555555556666444444444444444444444444444455550000fffff00ffffffffff00fffff000044444444444444444444444444445555444444444
000000000000000000000004444444400005555444455554444444400000ffffffffffffffffffffff0000044444444000055554444555544444444444444440
0000000000000000000000044444444000055554444555544444444000000ffffffffffffffffffff00000044444444000055554444555544444444444444440
00000000000000000000000444444440000555544445555444444440000000ffffffffffffffffff000000044444444000055554444555544444444444444440
00000000000000000000000444444440000555544445555444444440000000000ffffffffffff000000000044444444000055554444555544444444444444440
6660000666666666666666644440000444444444444444444440000000000000cccccccccccccd00000000044440000444444444444444444440000444400004
666000066666666666666664444000044444444444444444444000000000000ccccccccccccccdd0000000044440000444444444444444444440000444400004
666000066666666666666664444000044444444444444444444000000000000cccccccccccccddd0000000044440000444444444444444444440000444400004
66600006666666666666666444400004444444444444444444400000000000cccccccccccccddddd000000044440000444444444444444444440000444400004
66600005555555566666666444444445555555544440000444444440000fffcd0cccccccccddd0ddfff000044444444555555554444000044444444444444445
66600005555555566666666444444445555555544440000444444440000ffff000ccccccdddd000ffff000044444444555555554444000044444444444444445
66600005555555566666666444444445555555544440000444444440000ffff0000cccddddd0000ffff000044444444555555554444000044444444444444445
66600005555555566666666444444445555555544440000444444440000ffff00cccccccccccd00ffff000044444444555555554444000044444444444444445
6660000555555555555555544444444444444444444444444445555000000000cccd000000ccdd00000000044444444444444444444444444445555444444444
6660000555555555555555544444444444444444444444444445555000000000ccdd000000cccd00000000044444444444444444444444444445555444444444
666000055555555555555554444444444444444444444444444555500000000ccdd00000000ccdd0000000044444444444444444444444444445555444444444
666000055555555555555554444444444444444444444444444555500000000ccdd00000000ccdd0000000044444444444444444444444444445555444444444
00000000000000000000000444455554444444455554444444455550000077777770000000077777770000044445555444444445555444444445555444455554
00000000000000000000000444455554444444455554444444455550000777777770000000077777777000044445555444444445555444444445555444455554
00000000000000000000000444455554444444455554444444455550000777777770000000077777777000044445555444444445555444444445555444455554
00000000000000000000000444455554444444455554444444455550000777777770000000077777777000044445555444444445555444444445555444455554
44400004444444444444444000066666666666666666666666666664444444444440000444444444444444400000000666666666666777700000000444444444
44400004444444444444444000066666666666666666666666666664444444444440000444444444444444400000000666666666666777700000000444444444
44400004444444444444444000066666666666666666666666666664444444444440000444444444444444400000000666666666666777700000000444444444
44400004444444444444444000066666666666666666666666666664444444444440000444444444444444400000000666666666666777700000000444444444
44444444444555500004444000055555555666666666666666666660000555544444444444455550000444400006666666666667777777766660000000055554
44444444444555500004444000055555555666666666666666666660000555544444444444455550000444400006666666666667777777766660000000055554
44444444444555500004444000055555555666666666666666666660000555544444444444455550000444400006666666666667777777766660000000055554
44444444444555500004444000055555555666666666666666666660000555544444444444455550000444400006666666666667777777766660000000055554
44444444444444444445555000055555555555555555555555566664444444444444444444444444444555555555555666666666666777777776666444444444
44444444444444444445555000055555555555555555555555566664444444444444444444444444444555555555555666666666666777777776666444444444
44444444444444444445555000055555555555555555555555566664444444444444444444444444444555555555555666666666666777777776666444444444
4444444425ddd5244445555000055555555555555555555555566664444444444444444444444444444555555555555666666666666777777776666444444444
00055515d66666d24444444000000000000000000000000000000004444444400005555444455554444444455556666666677776666666666667777444444440
000555666d511d65444444400000000000000000000000000000000444444440000555544445555444444445555d666666677776666666666667777444444440
0005566d1000016d4444444000000000000000000000000000000004444444400005555444455554444444455666dddd66677776666666666667777444444440
00056610000000d654255520000000000000000000000000000000044444444000055554444555544444444566666666dd67777666666666ddd6777444444440
442d650000000056666666dddd66dd66666000066666666dddddddd5555000044444444444444444444000057d0005d666dd6666666777756666dd6444400004
4456d00000000005666d5d66666666d66660000666dddd666666666767666102222444444444444444400005750000015666ddd6666777d66dd66d6444400004
44d61000011110000000005d5100566d6660000ddd66666dd5555555555d6666666ddd55524444425520000165000000005d676d66677d665001d6d444400004
4266000016776666665000000000066d6660000d666d5100000000000000155555d6666666d5522d766d51057500000000000d67d666d6610000166244400004
556d000017777777777d00000000057d666001d6d1000000000000000000000000000005d6666666dd66666661000000000000566ddd67d00000056544444445
5d610000577777777777d00000000166ddd5d67d0055555510000000000000000000000000015d6d00015ddd1000000000000005776665000000006624444445
166000005777777777777d0000000056766666500167777776101000000000000000000000000000000d666666666ddd10001000dd510000000000d624444445
16d0000057777777777777d0001110015555110016777777776566d510000000000000000000000000067777777777761156d0000000005d000000d654444445
565000005666d7777777777d056766dd51000000d7777777777667776500000000000000000000000001555677777776d6776000000056761000005654444444
56d000001100d77777767777d777777776d0000577777777777767777d1551100000000000000000000000167776777677776000000d77761000005654444444
2d6d1000000067777765d77767766d6777d0001677777777777767777d6777665d6ddddddd5555551111005777767776777760000016777615dd5d6654444444
426766d50001677777776677667500677760006777777d77777767777dd77767d67777777777777776666567777d7776d777d00000167776567676d544444444
445d66765005777777777777d67d006777600d7777776d7777776777765777666d7777777777777777777d67776577765777d000000167765650510444455554
444425d7610d77777ddd6777dd76006777605677777611dd666667777616777dd5777777777777777777767777d577765777d00000006776d61000025dd55554
4444442d76067777767765d65576106777616777777500000000d7777606777d016777777777777777777677775577765777d00000016776d610001666666554
444444457d06777776677d00016750d7776d777777d000000000d77776d677760066d777777777777777677776057776577750000001677656100566d55d7654
4440000d655777777dd776100067d1d7776677777610005666d5577777777776105d577776155555567667777d0d7776d777500000016776166d66650000d754
4440000660d77777751677d000d77667776677777766d5d7777d57777767776d50015777761000001665677776677776d7775000000577760d666d10000056d4
44400016506777776005777500577777776677777777776777765777775567777d05677777666650000577777666777dd77750000005777d00000000000006d2
444000d611677777d000677600067777776d667777777777777657777750d7777500677777777610000d7777d00d777dd77750000155777d0000000000000d61
4444426d05777777d00056665001d6677761015d67777777766d167777d1677761001577776dd50000167776100d777dd77755d6666d777d0155d6d000000d65
4444456501d667761000011100000015d661000005d667765100067777d57777d00001677761000000577776000d76dd6777777777657776667777d000000d75
44444565000015dd000000001510000000100000000015d50000067777d6777750000067777500015d677775000d77776777777777dd77777777761000001662
44444d610000000000000001d7665000000000000155dd500000067777667776dd0000d77765005677766dd10006777767777777761d777777777d05dd51d654
44444d7d51000000000005d676d66d10000000d66666666100000d77776d67766d0000576d10001dd5510000000677766777666d510d77777766d1d777777654
444442d77666d5000000d66d5005d66500000d66dd5515650000015d67601d7761000005100005d100000000000d6d51ddd51000000d766dd510016d5666d244
44444425555666d1000d7d1000055d776d55d6d15555557d0000000001500056d00000000000d676d510000000000000000000000001100000000d7d42224444
4444444444425d66666665500005555d667765555555556d000000000000000000000000000166d66666dd100000000011000000000000000000066544444444
000555544445555d666d54400000000001550000000000d6d555000000111100000000000000d75455d6776000000056666d5510000000001555d76244444440
00055554444555542244444000000000000000000000000d6666ddd666666666d51d50000000d65444455d7d00001d66dd666761000015d66676665444444440
000555544445555444444440000000000000000000000000111666666dd55dd6666676ddd65d6d54444445d76ddd66d000055d7d55d66666ddd5524444444440
000555544445555444444440000000000000000000000000000000022444444001155d676666d5544444445d6666d520000555d6666dd5524444444444444440
44444444444444444440000666666666666000066666666666666664444000044444421555d52444444000021110000444444425dd5244444440000444400004
44444444444444444440000666666666666000066666666666666664444000044444444444444444444000044440000444444444444444444440000444400004
44444444444444444440000666666666666000066666666666666664444000044444444444444444444000044440000444444444444444444440000444400004
44444444444444444440000666666666666000066666666666666664444000044444444444444444444000044440000444444444444444444440000444400004
55555554444000044444444666666666666000055555555666666664444444455555555444400004444444444444444555555554444000044444444444444445
55555554444000044444444666666666666000055555555666666664444444455555555444400004444444444444444555555554444000044444444444444445
55555554444000044444444666666666666000055555555666666664444444455555555444400004444444444444444555555554444000044444444444444445
55555554444000044444444666666666666000055555555666666664444444455555555444400004444444444444444555555554444000044444444444444445
44444444444444444445555555555556666000055555555555555554444444444444444444444444444555544444444444444444444444444445555444444444
44444444444444444445555555555556666000055555555555555554444444444444444444444444444555544444444444444444444444444445555444444444
44444444444444444445555555555556666000055555555555555554444444444444444444444444444555544444444444444444444444444445555444444444
44444444444444444445555555555556666000055555555555555554444444444444444444444444444555544444444444444444444444444445555444444444
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
1805000011574160741357418074155641a064165641b054185541d0541a7541f5441b044217441d544220441f744245342103426734220242772424014297140070400704007040070400704007040070400704
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
010f00000c033225152e5153a515246152b7070a145350150c003290153200529005246152501526015220150c0331e0251f0252700524615225051a0152250522015225152201522515246150a7110a0001d005
010f000007135061350000009135071351f711000000510505135041350000007135051351c0151d0150313503135021350000005135031350a1050a135000000113502135031350413505135000000a13500000
010f00000c03300000300152401524615200150c013210150c003190151a01500000246153c70029515295150c0332e5052e5150c60524615225150000022515297172b71529014297152461535015295151d015
010f000005135051050c00005135091351c0150c1351d0150a1351501516015021350713500000051350000003135031350013500000021351b015031351a0150513504135000000713505135037153c7001b725
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
00 37367440
00 37367440
01 37367440
00 37367440
00 35347440
02 35347440
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
@5600
0405070000010000000000000060770067200061770006060000000000667707010000006007270000000020007070000000001060002011100010210000067113111311133312133313333311313333520071750717377777667650661712737707770177776677017707770100700077077701777766770000007001007070
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000010101000100000005050000000000000a1f0a1f0a0000000207030607020000050402010500000002050e050e0000000101000000000000020101010200000001020202010000000502070205000000000207020000000000000000010100000000070000000000000000000100000004040201010000
0002050505020000000203020207000000030402010700000003040204030000000505070404000000070103040300000006010305020000000704040202000000020502050200000002050604030000000001000100000000000001000101000000020102000000000003000300000000000102010000000003040200020000
0006090d0106000000000306050700000001030505030000000006010106000000040605050600000000020503060000000402070202000000000605060403000001010305050000000100010101000000020002020201000001050305050000000101010102000000000f151515000000000305050500000000020505020000
000003050503010000000605050604000000030501010000000006030603000000020702020600000000050505020000000005050503000000001111150a000000000502050500000000050505060300000007060307000000030101010300000001020202040000000302020203000000020500000000000000000000070000
0002040000000000000205070505000000030503050300000006010101060000000305050503000000070103010700000007010301010000000e010d090600000005050705050000000101010101000000040404050200000005050305050000000101010107000000111b151111000000090b0f0d0900000006090909060000
0003050301010000000609090d06080000030503050500000006010204030000000702020202000000090909090600000009090905020000001111151b1100000005050205050000000505020202000000070402010700000006020102060000000101000101000000030204020300000000000a050000000003030000000000
003e6b776b3e000000040e1f0e040000001f0e040e1f0000001b1f1f0e040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00005500000000003e7363733e000000081c7f3e220000003e1c081c3e0000003e7763633e000000000552200000000000112a44000000003e6b776b3e0000007f007f007f00000055555555550000000e041e2d2600000011212125020000000c1e20201c000000081e08241a0000004e043e4526000000225f12120a000000
1e083c1106000000100c020c10000000227a2222120000001e2000023c000000083c10020c000000020202221c000000083e080c08000000123f12021c0000003c107e043800000002073202320000000f020e101c0000003e404020180000003e10080810000000083804023c00000032071278180000007a42020a72000000
093e4b6d660000001a272273320000003c4a494946000000123a123a1a000000236222221c0000000c00082a4d000000000c1221400000007d79113d5d0000003e3c081e2e00000006247e2610000000244e04463c0000000a3c5a46300000001e041e4438000000143e2408080000003a56523008000000041c041e06000000
08023e201c00000022222620180000003e1824723000000004362c26640000003e182442300000001a272223120000000e641c28780000000402062b1900000000000e1008000000000a1f120400000000040f150d00000000040c060e0000003e2014040200000030080e0808000000083e2220180000003e0808083e000000
107e181412000000043e242232000000083e083e080000003c24221008000000047c1210080000003e2020203e000000247e242010000000062026100c0000003e20101826000000043e240438000000222420100c0000003e222d300c0000001c083e08040000002a2a20100c0000001c003e080400000004041c2404000000
083e080804000000001c00003e0000003e2028102c000000083e305e08000000202020100e0000001024244442000000021e02021c0000003e2020100c0000000c12214000000000083e082a2a0000003e201408100000003c003e001e000000080424427e00000040281068060000001e041e043c000000043e240404000000
1c1010103e0000001e101e101e0000003e003e201800000024242420100000001414145432000000020222120e0000003e2222223e0000003e2220100c0000003e203c2018000000062020100e000000001510080600000000041e140400000000000c081e000000001c18101c00000008046310080000000810630408000000
__meta:1bdaec14-d23c-4c68-9cbb-45d80342eabf__
{
	["SFXname"] = {
		[52] = "",
		[17] = "",
		[53] = "",
		[54] = "",
		[55] = "",
		[27] = "",
	},
	["MusicName"] = {
		[0] = "",
		[1] = "",
		[2] = "",
		[3] = "",
		[4] = "",
		[5] = "",
		[6] = "",
		[7] = "",
		[8] = "",
		[9] = "",
	},
	["pico8"] = {
	},
}
