//By xXxMoNkEyMaNxXx aka Rhys

/*
The MIT License (MIT) obtained from http://choosealicense.com/licenses/mit/

Copyright (c) 2014 Rhys Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

uniform vec2 Blur;//directed blur in pixels
uniform vec2 CanvasSize;//Size of canvas being operated on in pixels
uniform vec2 CanvasOffset;//Pixel offset from top left of canvas

float solvedIntegral(vec2 dp,float dt)
{
	return abs(dt*(dt*(dt*Blur.x*Blur.y/3+dot(Blur,dp.yx)/2)+dp.x*dp.y));//Absolute value 4 life
}

vec4 effect(vec4 _0,sampler2D image,vec2 _2,vec2 _3)
{
	vec2 p=CanvasOffset+CanvasSize*_2-vec2(0.5);
	vec2 ip=p;//Common vertex of the pixels being considered
	if(Blur.x>0)
		++ip.x;
	if(Blur.y>0)
		++ip.y;
	float t=0;//This has the integral's respect.
	vec4 colour=vec4(0);//Running integral
	while(t<1){//Useless escape condition
		vec2 dp=ip-(p+Blur*t);//Convoluted preprocessing
		float dtx=2;//dt to next integer x (2 is a nonsensical value that will behave well if the blur is purely vertical)
		if(Blur.x>0)
			dtx=dp.x/Blur.x;
		else if(Blur.x<0)
			dtx=(dp.x-1)/Blur.x;
		float dty=2;//dt to next int y
		if(Blur.y>0)
			dty=dp.y/Blur.y;
		else if(Blur.y<0)
			dty=(dp.y-1)/Blur.y;
		float dtmax=1-t;//dt to end of path
		float dt=min(dtmax,min(dtx,dty));//Whichever comes first: path ends, path crosses an integer on x, path crosses an integer on y
		//HUGE simplification over the old shader!
		float w00=solvedIntegral(vec2(0,0)-dp,dt);//Volume covered by top left pixel
		float w10=solvedIntegral(vec2(1,0)-dp,dt);//top right
		float w01=solvedIntegral(vec2(0,1)-dp,dt);//bl
		float w11=solvedIntegral(vec2(1,1)-dp,dt);//br
		float lsq=w00+w10+w01+w11;//Total volume covered this iteration (treated as an area).  Probably not 1.
		//Very complicated and efficient simplification! At least 50% better performance :D
		colour+=lsq*texture2D(image,(ip-vec2(w00+w01,w00+w10)/lsq)/CanvasSize);//The individual volumes are used to find an Blur from the common vertex that will generate a colour, which, when it is linearly interpolated, will have the same proportions of the four colours as the expanded algorithm, and then scaled to the actual contribution of the sum.
		if(dt==dtmax)//Final step of the integral was processed
			break;
		else
			t+=dt;
		if(dt==dtx){
			if(Blur.x>0)
				++ip.x;
			else
				--ip.x;
		}
		if(dt==dty){//No 'else' in case the path crosses directly over a vertex
			if(Blur.y>0)
				++ip.y;
			else
				--ip.y;
		}
	}
	return colour;
}
