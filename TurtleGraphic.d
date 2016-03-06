import derelict.sdl2.sdl;
import std.stdio;
import std.math;
import std.algorithm;
import std.array;
import std.parallelism;

class TurtleGraphic{
	double[][] polygon;
	double[][] stack;
	double cx,cy,cz;
	bool pen=true,record=false;
	double turtleX=0.0,turtleY=0.0,direction=0.0;	//座標(x,y),向き
	double fowardDistance=1.0;
	int winX,winY;
	SDL_Window* window;
	SDL_Renderer* renderer;
	ubyte[4]
		color=[0,0,0,255],//.map!("cast(ubyte)a");
		fill_color=[255,255,255,255];
	SDL_Surface* surface;
	SDL_Texture* texture;
	this(){
		cx=0.0;
		cy=0.0;
		cz=1.0;
	}

	void penup(){ pen=false; }
	void pendown(){ pen=true; }

	void beginPoly(){ this.polygon=[];record=true; }
	void endPoly(){ record=false; }
	double[][] getPoly(){ return polygon; }

	void setPosition(double x,double y,double radian){
		if(pen){
			SDL_SetRenderDrawColor(renderer, color[0], color[1], color[2], color[3]);
			SDL_RenderDrawLine(renderer,cast(int)x,cast(int)y,cast(int)turtleX,cast(int)turtleY);
		}
		if(record) polygon~=[turtleX,turtleY,x,y];
		turtleX=x;
		turtleY=y;
		direction=radian;
	}

	void foward(){
		this.foward(this.fowardDistance);
	}

	void foward(double distance){
		double beforeX=turtleX,beforeY=turtleY;
		turtleX+=distance*cos(direction);
		turtleY+=distance*sin(direction);
		if(pen){
			SDL_SetRenderDrawColor(renderer, color[0], color[1], color[2], color[3]);
			SDL_RenderDrawLine(renderer,cast(int)beforeX,cast(int)beforeY,cast(int)turtleX,cast(int)turtleY);
		}
		if(record) polygon~=[beforeX,beforeY,turtleX,turtleY];
	}

	//数学的なY軸と画面上のY軸は異なるので回転の向きに注意
	void turnRight(double radian){
		direction+=radian;
	}

	void turnLeft(double radian){
		direction-=radian;
	}

	void setColor(ubyte[4] color){
		this.color=color;
	}

	void push(){
		stack=[turtleX,turtleY,direction]~stack;
	}

	void pop(){
		turtleX=stack[0][0];
		turtleY=stack[0][1];
		direction=stack[0][2];
		stack=stack.remove(0);
	}

	void makeWindow(uint winX,uint winY){
		this.winX=winX;
		this.winY=winY;
		DerelictSDL2.load();
		SDL_Init(SDL_INIT_VIDEO);
		window = SDL_CreateWindow("L-System",50,50,winX,winY,SDL_WINDOW_SHOWN);
		renderer=SDL_CreateRenderer(window,1,0);
		surface=SDL_CreateRGBSurface(0,winX,winY,32,0xff000000,0x00ff0000,0x0000ff00,0x000000ff);
		texture=SDL_CreateTextureFromSurface(renderer,surface);
	}

	void drawPoly(){
		assert(window!=null);
		assert(polygon.length>0);
		if(window==null) return;

		SDL_SetRenderDrawColor(renderer, fill_color[0], fill_color[1], fill_color[2], fill_color[3]);
		SDL_RenderClear(renderer);

		double maxX=reduce!((double a,double[] b){ return max(a,max(b[0],b[2])); })(0.0,polygon);
		double maxY=reduce!((double a,double[] b){ return max(a,max(b[1],b[3])); })(0.0,polygon);
		double minX=reduce!((double a,double[] b){ return min(a,min(b[0],b[2])); })(polygon[0][0],polygon);
		double minY=reduce!((double a,double[] b){ return min(a,min(b[1],b[3])); })(polygon[0][1],polygon);
		double rangeX=maxX-minX;
		double rangeY=maxY-minY;
		double centerX=(maxX+minX)/2.0;
		double centerY=(maxY+minY)/2.0;

		//ディープコピー
		double[][] tmpPolygon=polygon.map!("a.dup").array();

		//描画サイズを変える
		tmpPolygon=tmpPolygon.map!((double[] a){a[]-=[winX/2.0,winY/2.0,winX/2.0,winY/2.0][]-[cx,cy,cx,cy][];return a;})	//ウィンドウの中央が原点になるようにする
												 .map!((double[] a){a[]*=cz;return a;})																											//拡大縮小
												 .map!((double[] a){a[]+=[winX/2.0,winY/2.0,winX/2.0,winY/2.0][]-[cx,cy,cx,cy][];return a;})	//原点を元に戻す
												 .array();

		//描画位置を変える
		tmpPolygon=map!((double[] a){a[]+=[cx,cy,cx,cy][];return a;})(tmpPolygon).array();


		foreach(double[] p;tmpPolygon.parallel()){
			int[] int_p=p.map!("cast(int)a").array();
			SDL_SetRenderDrawColor(renderer, color[0], color[1], color[2], color[3]);
			SDL_RenderDrawLine(renderer,int_p[0],int_p[1],int_p[2],int_p[3]);
		}
	}


	void viewPoly(){
		bool running= true;
		while(running){
			SDL_Event e;
			while (SDL_PollEvent(&e)){
				switch (e.type){
					case SDL_QUIT:
						import std.c.stdlib;
						exit(0);
						break;
					case SDL_KEYDOWN:
						running = false;
						break;
					case SDL_MOUSEMOTION:
						if( (e.motion.state&3) != 0){	//右クリックとホイールクリック
							cx+=e.motion.xrel/cz;
							cy+=e.motion.yrel/cz;
						}
						break;
					case SDL_MOUSEWHEEL:
						if(e.wheel.y>0) cz*=1.1;
						if(e.wheel.y<0) cz/=1.1;
						break;
					default:
						break;
				}

				SDL_RenderClear(renderer);
				drawPoly();
				SDL_RenderPresent(renderer);
			}
		}
	}





	void display(){
		if(window==null) return;
		/*
		SDL_RenderClear(renderer);
		SDL_Rect rect;
		SDL_GetClipRect(surface,&rect);
		SDL_UpdateTexture(texture,&rect,surface.pixels,1);
		SDL_RenderCopy(renderer,texture,null,&rect);
		*/
		SDL_RenderPresent(renderer);
	}
}


unittest{
	TurtleGraphic tg=new TurtleGraphic();
	tg.makeWindow(500,500);
	tg.pendown();
	tg.setPosition(100,100,0.0);
	tg.beginPoly();
	tg.foward(20);
	tg.endPoly();
	tg.viewPoly();
}
