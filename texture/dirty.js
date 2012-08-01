//Dirty background
// Yes it sucks, it's temporary
var start = Date.now();
var width=1024;
var height=1024;
var canvas = document.createElement('canvas');
canvas.width=width;
canvas.height=height;
var ctx = canvas.getContext('2d');

var rnd256 = function(){return Math.floor(Math.random()*256);};
var col = function(r,g,b,a){return 'rgba('+Math.floor(r)+','+Math.floor(g)+','+Math.floor(b)+','+a+')';};
var state = 0.5;
var r = 0.5;
var dirtFnc = function(x,y){
    var lum =0;//rnd256();
    state = state * r + Math.random() * (1-r);
    
    return col(state*256,state*256,state*256,1.0);
};

var x,y;
for (y=0;y<height;y++){
    for (x=0;x<width;x++){
        ctx.fillStyle = dirtFnc(x,y);
        ctx.fillRect(x,y,1,1);
    }    
}

var base64 = canvas.toDataURL();

var dirtydiv = document.createElement('div');
dirtydiv.style.position = 'absolute';
dirtydiv.style.top = '0px';
dirtydiv.style.bottom = '0px';
dirtydiv.style.left = '0px';
dirtydiv.style.right = '0px';
dirtydiv.style.backgroundColor = "rgba(0,0,0,1.0)";
dirtydiv.style.backgroundAttachment= "fixed";

dirtydiv.style.backgroundImage = "url("+base64+")";
document.body.appendChild(dirtydiv);
//document.getElementById('bg_dirt').appendChild(canvas);

var time = Date.now()-start;
console.log("Time taken: ", time);