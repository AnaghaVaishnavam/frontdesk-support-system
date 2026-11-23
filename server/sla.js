// Arvo working calendar: Mon-Fri, 09:30-18:30, excluding configured dates.
const HOLIDAYS=(process.env.HOLIDAYS||'').split(',').filter(Boolean);
const START=9*60+30, END=18*60+30;
function parts(d){return {y:d.getFullYear(),m:d.getMonth(),day:d.getDate(),dow:d.getDay()};}
function isWorkday(d){const p=parts(d),key=`${p.y}-${String(p.m+1).padStart(2,'0')}-${String(p.day).padStart(2,'0')}`;return p.dow!==0&&p.dow!==6&&!HOLIDAYS.includes(key);}
function atMinute(d,n){const x=new Date(d);x.setHours(Math.floor(n/60),n%60,0,0);return x;}
function nextStart(d){let x=new Date(d);x.setDate(x.getDate()+1);x=atMinute(x,START);while(!isWorkday(x)){x.setDate(x.getDate()+1);}return x;}
function normalize(d){let x=new Date(d);while(true){if(!isWorkday(x)){x.setDate(x.getDate()+1);x=atMinute(x,START);continue;}const mins=x.getHours()*60+x.getMinutes();if(mins<START)return atMinute(x,START);if(mins>=END){x=nextStart(x);continue;}return x;}}
function addBusinessMinutes(input,minutes){let x=normalize(input),left=minutes;while(left>0){const end=atMinute(x,END),available=Math.max(0,(end-x)/60000);if(left<=available){x=new Date(x.getTime()+left*60000);left=0;}else{left-=available;x=nextStart(x);}}return x;}
function businessMinutesBetween(start,end){let x=new Date(start),to=new Date(end),total=0;if(to<=x)return 0;while(x<to){x=normalize(x);if(x>=to)break;const e=atMinute(x,END),stop=e<to?e:to;total+=Math.max(0,(stop-x)/60000);x=nextStart(x);}return total;}
function targets(priority,created){const mins=priority==='urgent'?[120,540]:priority==='medium'?[270,3*540]:[540,5*540];return {reply:addBusinessMinutes(created,mins[0]),resolve:addBusinessMinutes(created,mins[1])};}
module.exports={addBusinessMinutes,businessMinutesBetween,targets};
