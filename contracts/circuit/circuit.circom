pragma circom 2.0.0;

template Multiplier(n) {
    signal input a;
    signal input b;
    signal output c;

    signal int[n];

    int[0] <== a*a + b;
    for (var i=1; i<n; i++) {
    int[i] <== int[i-1]*int[i-1] + b;
    }

    c <== int[n-1];
}

function size(arr) {
  var i = 0;
  while (arr[i] != 0) {
    i++;
  }
  return i;
}

template BellmanFord(n) {
  signal input vertices[n];
  signal input edgeSrc[n*n];
  signal input edgeDst[n*n];
  signal input weights[n*n];
  signal input source;
  signal output distances[n];

  var dists[n];
  var preds[n];

  for (var i = 0; i < n; i++) {
    dists[i] = 10000000000000;
    preds[i] = -1;
  }

  dists[source] = 0;

  // get number of vertices
  var nVertices = size(vertices);
  var nEdges = size(edgeSrc);

  for (var i = 0; i < nVertices-1; i++) {
    for (var j = 0; j < nEdges; j++) {
      var u = edgeSrc[j];
      var v = edgeDst[j];
      var w = weights[j];
      if (dists[v] > dists[u] + w) {
        dists[v] = dists[u] + w;
        preds[v] = u;
      }
    }
  }

  for (var i = 0; i < n; i ++) {
    distances[i] <== dists[i];
  }
}

component main {public [vertices, edgeSrc, edgeDst, weights, source]} = BellmanFord(32);
