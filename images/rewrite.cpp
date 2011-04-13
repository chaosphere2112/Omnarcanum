#include <iostream>
#include <fstream>
#include <string>

using namespace std;

int main(){
	ifstream io;
	ofstream of;
	
	io.open("Map1.tmx",ios_base::in);
	of.open("Map1.txml", ios_base::out);
	string in;
	int counter=0;
	while (io>>in){
		of<<in;
		if (in=="<tile")
			counter++;
		if (counter==49)
		{
			counter=0;
			io>>in;
			of<<in;
			of<<"<row id="<<'"'<<rownum<<'"'<<">"
		}
	}

}
