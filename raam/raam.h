#include <assert.h>

#include <iterator>
#include <map>

#include <math.h>

#include <string>
#include <iostream>
#include <sstream> 
#include <fstream>


using std::cout;
using std::cerr;
using std::endl;
using std::map;
using std::vector;
using std::string;
using std::stringstream;
using std::ofstream;

class Graph;
class Agent;
class Resource;
class Edge;

class Graph {

  public:
    
    Graph(float alpha = 0.5, float tol = 0.01);

    void new_agent   (long long _id, int _pop);
    void new_resource(long long _id, int _pop);
    void new_edge    (long long _agent, long long _resouce, float cost);

    void allocate_min_fixed();
    void equalize_use(unsigned int cycles = 1);

    void write(string filename);

  private:

    float _alpha, _tol;

    map<long long, int> _addrA;
    map<long long, int> _idenA;

    map<long long, int> _addrR;
    map<long long, int> _idenR;

    vector<Agent*>    _agents;
    vector<Resource*> _resources;
    vector<Edge*>     _edges;

};

class Agent {

  public:
    
    Agent();
    Agent(long long id, int demand, float alpha, float tol);

    void add_edge(Edge* e) { _edges.push_back(e); }

    string get_string();

    long long get_id()        { return _id; }
    int       get_demand()    { return _demand; }
    int       get_n_choices() { return _edges.size(); }

    float     get_avg_cost();

    void allocate_min_fixed();
    void equalize_use(int max_moves = 0);

  private:

    long long _id;

    unsigned int _demand;

    float _alpha, _tol;

    vector<Edge*> _edges;

};

class Resource { 

  public:

    Resource();
    Resource(long long id, unsigned int supply);

    long long get_id()        { return _id; }
    int       get_supply()    { return _supply; }
    int       get_demand()    { return _demand; }
    int       get_n_agents()  { return _edges.size(); }
    int       get_rDS()       { return _demand / _supply; }

    void add_edge(Edge* e) { _edges.push_back(e); }

    void change_demand(int d_use) { _demand += d_use; }

  private:

    long long _id;
    unsigned int _supply;
    unsigned int _demand;
    vector<Edge*> _edges;

};

class Edge {

  public:
    
    Edge();
    Edge(Agent* agent, Resource* resource, float cost);

    long long get_agent_id()    { return _agent   ->get_id(); }
    long long get_resource_id() { return _resource->get_id(); }

    Agent*    agent   () { return _agent; }
    Resource* resource() { return _resource; }

    int  get_use() { return _use; }
    void set_use(unsigned int use);

    bool is_used() { return _use > 0; }


    float fixed_cost()  { return _cost / 15; }
    float supply_cost() { return _resource->get_rDS() / 1e3; }

    float total_cost(float alpha);

  private:

    Agent* _agent;
    Resource* _resource;
    float _cost;
    int   _use;

};


Graph::Graph(float alpha, float tol) :
  _alpha(alpha), _tol(tol) {}

void Graph::new_agent(long long id, int demand) {

  assert(_addrA.find(id) == _addrA.end());

  _addrA[id] = _agents.size();
  _idenA[_agents.size()] = id;

  _agents.push_back(new Agent(id, demand, _alpha, _tol));

}

void Graph::new_resource(long long id, int demand) {

  assert(_addrR.find(id) == _addrR.end());

  _addrR[id] = _resources.size();
  _idenR[_resources.size()] = id;

  _resources.push_back(new Resource(id, demand));

}


void Graph::new_edge(long long agent_id, long long resource_id, float cost) {

  if (_addrA.find(agent_id) == _addrA.end()) cerr << agent_id << endl;

  assert(_addrA.find(agent_id)    != _addrA.end());
  assert(_addrR.find(resource_id) != _addrR.end());

  if (!_resources[_addrR[resource_id]]->get_supply()) return;

  _edges.push_back(new Edge(_agents[_addrA[agent_id]], _resources[_addrR[resource_id]], cost));

  _agents   [_addrA[agent_id]]   ->add_edge(_edges.back());
  _resources[_addrR[resource_id]]->add_edge(_edges.back());

}


void Graph::allocate_min_fixed() {

  for (auto a : _agents) {

    a->allocate_min_fixed();

  }

}

void Graph::equalize_use(unsigned int cycles) {

  for (unsigned int ci = 0; ci < cycles; ci++) {

    int ni = 0;
    for (auto agent : _agents) {

      agent->equalize_use();

      ni++;
    }
  }

}

void Graph::write(string filename) {

  ofstream ofile;
  ofile.open(filename);

  for (auto a : _agents) {
    ofile << a->get_string();
  }

  ofile.close();

}



Agent::Agent(long long id, int demand, float alpha, float tol) : 
  _id(id), _demand(demand), _alpha(alpha), _tol(tol) { };


string Agent::get_string() {

  float cost = get_avg_cost();

  stringstream ss;
  if (!std::isnan(cost)) ss << _id << "," << cost << endl;

  return ss.str();

}

float Agent::get_avg_cost() {

  float cost(0);

  for (auto e : _edges) {
    if (e->is_used()) {
      cost += e->get_use() * e->total_cost(_alpha);
    }
  }

  return cost / _demand;

}

void Agent::allocate_min_fixed() {

  Edge* min_edge(0); float min_cost(1e10);

  for (auto e : _edges) {

    e->set_use(0);

    float mcost = e->fixed_cost();

    if (mcost < min_cost) {
      min_cost = mcost;
      min_edge = e;
    }
  }

  if (min_edge) min_edge->set_use(_demand);

}


void Agent::equalize_use(int max_moves) {

  Edge* min_edge(0); float min_cost(1e11);
  Edge* max_edge(0); float max_cost(0);


  for (auto e : _edges) {

    float mcost = e->total_cost(_alpha);

    if (mcost < min_cost) {
      min_cost = mcost;
      min_edge = e;
    }

    if (!e->is_used()) continue;
    
    if (mcost > max_cost) {
      max_cost = mcost;
      max_edge = e;
    }

  }

  if (min_edge && max_edge && min_edge != max_edge) {

    if (fabs(max_cost - min_cost) < _tol) return;

    float Dtot = min_edge->resource()->get_demand() + max_edge->resource()->get_demand();

    float smin = min_edge->resource()->get_supply();
    float smax = max_edge->resource()->get_supply();

    float tmin = min_edge->fixed_cost();
    float tmax = max_edge->fixed_cost();

    int dmin = ceil (((smin * smax) / (smin + smax)) * (Dtot/smax + 1000 * ((1 - _alpha)/_alpha) * (tmax - tmin)));
    int dmax = floor(((smin * smax) / (smin + smax)) * (Dtot/smin + 1000 * ((1 - _alpha)/_alpha) * (tmin - tmax)));

    assert(abs(Dtot - dmin - dmax) <= 1);

    // int delta_min = dmin - min_edge->resource()->get_demand();
    int delta_max = max_edge->resource()->get_demand() - dmax;

    if (delta_max < 0) return; // cheap fix...
    assert(delta_max >= 0);

    int delta = delta_max;
    if (delta > max_edge->get_use()) {
      delta = max_edge->get_use();
    }

    assert(delta >= 0);

    min_edge->set_use(min_edge->get_use() + delta);
    max_edge->set_use(max_edge->get_use() - delta);

  }

}

Resource::Resource(long long id, unsigned int supply) : 
  _id(id), _supply(supply), _demand(0) { };

Edge::Edge(Agent* agent, Resource* resource, float cost) :
  _agent(agent), _resource(resource), _cost(cost), _use(0) { }


void Edge::set_use(unsigned int use) {

  unsigned int d_use = use - _use;
  _use = use;

  _resource->change_demand(d_use);

}


float Edge::total_cost(float alpha) {

  return alpha * supply_cost() + (1 - alpha) * fixed_cost();

}


