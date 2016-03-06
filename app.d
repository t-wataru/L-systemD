import LSystem;
import TurtleGraphic;
import std.math;
import std.stdio;
import std.algorithm;

//サンプル
void main(){
	int winX=1000,winY=1000;
	LSystem ls=new LSystem("F");
	TurtleGraphic tg=new TurtleGraphic();

	//L-Systemの置換ルールの連想配列
	string[dchar] rewriteRule=[
		'F':"F[+F]F[-F]F",
		'+':"+",
		'-':"-",
		'[':"[",
		']':"]"
	];

	//L-Systemの記号とタートルグラフィックのメソッドの連想配列
	int delegate()[dchar] functionDict=[
		'F':(){tg.foward(10.0);return 1;},
		'+':(){tg.turnRight(2.0*PI*0.05);return 1;},
		'-':(){tg.turnLeft(2.0*PI*0.05);return 1;},
		'[':(){tg.push();return 1;},
		']':(){tg.pop();return 1;}
	];

	auto turtleFunction=delegate(char toaken){
		functionDict[toaken]();
	};

	tg.makeWindow(winX,winY);

	/+
	タートルグラフィックスの使い方がめんどくさい
	もっとシンプルに使えるようにしたい
	そもそもタートルグラフィックスである必要があるのか？
	+/
	foreach(i;0..10){
		tg.penup();
		tg.setPosition(winX/2,winY-20,2.0*PI*0.75);
		tg.pendown();
		tg.beginPoly();
		ls.processToakens(turtleFunction);
		//ls.toakens.map!(a=>functionDict[a]()).writeln();//動いてしまった
		ls.replaceAllToakens(rewriteRule);
		tg.endPoly();
		tg.viewPoly();
	}
}
