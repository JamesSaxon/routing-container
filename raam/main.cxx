// g++ main.cxx -std=c++0x -Wall -o raam -lpthread && ./raam

#include "stdio.h"
#include "string"
#include "math.h"
#include <vector>
#include <iomanip>
#include <list>
#include <iostream>
#include <fstream>

#include "csv.h"

#include "raam.h"

using std::cout;
using std::endl;

int main(){

  Graph g(0.4, 0.001);

  // io::CSVReader<3> node_csv("temp_doc_pop.csv");
  io::CSVReader<3> node_csv("data/doc_pop.csv");
  node_csv.read_header(io::ignore_extra_column, "geoid", "doc", "pop");
  long long geoid; int doc, pop;
  while(node_csv.read_row(geoid, doc, pop)){

    int state = geoid/1000000000;
    if (state != 17 && state != 18 && state != 19 && state != 27 && state != 55) continue;

    g.new_resource(geoid, doc);
    g.new_agent(geoid, pop);
    g.new_edge(geoid, geoid, 0);
  }

  io::CSVReader<3> edge_csv("data/times.csv");
  edge_csv.read_header(io::ignore_extra_column, "origin", "destination", "cost");
  long long geoid1; long long geoid2; float cost;
  while(edge_csv.read_row(geoid1, geoid2, cost)){

    int state1 = geoid1/1000000000;
    int state2 = geoid2/1000000000;

    if (state1 != 17 && state1 != 18 && state1 != 19 && state1 != 27 && state1 != 55) continue;
    if (state2 != 17 && state2 != 18 && state2 != 19 && state2 != 27 && state2 != 55) continue;

    g.new_edge(geoid1, geoid2, cost);
  }

  g.allocate_min_fixed();

  g.write("test_000.csv");

  for (int x = 1; x <= 20; x++) {
    g.equalize_use(1);
    cout << x << endl;

    char fstr[13]; 
    sprintf(fstr, "test_%03d.csv", x);
    g.write(fstr);
  }

  return 0;
}

