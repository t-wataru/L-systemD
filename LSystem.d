import std.array;
import std.algorithm;
import std.stdio;
import std.math;
import TurtleGraphic;

/+
L-System自体がシンプルなので、クラスでくくる必要が感じれられない
TODO:十分にシンプルになったらクラスを解体したい、toakensが丸見えになるからいやらしくなるかも
+/
class LSystem{
	string toakens;

	//firstToakens:トークンの書き換える前のはじめの状態
	this(string firstToakens="F"){
		this.toakens=firstToakens;
	}

	/+
	文字列の書き換えとTurtleGraphicesの描画を両方処理できるようにした結果（できてない）
	結果的にTurtleGraphicesの描画にしか使ってない
	+/
	void processToakens(T)(void delegate(T) dg){
		//map!(dg)(toakens);
		foreach(char toaken;toakens) dg(toaken);
	}

	/+
	L-Systemの書き換えをする
	連想配列のキーがdcharとかcharとかstringとかめんどくさいので横着してテンプレート
	書き換えルールの例：rewriteRule={"a":"ab", ……};
	+/
	void replaceAllToakens(T)(string[T]rewriteRule){
		toakens=toakens.map!(a=>rewriteRule[a]).join();
	}
}
