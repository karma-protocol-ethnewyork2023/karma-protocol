pragma circom 2.0.0;

include "./circuits/mux1.circom";
include "./circuits/comparators.circom";

template Min() {
  signal input a;
  signal input b;
  component mux = Mux1();
  component lt = LessThan(16);
  signal output out;

  lt.in[0] <== a;
  lt.in[1] <== b;

  mux.c[0] <== a;
  mux.c[1] <== b;
  mux.s <== lt.out;
  out <== mux.out;
}

template MultiMin(n) {
  signal input in[n];
  component min;
  component min2;
  signal output out;
  component multimin;

  if (n == 1) {
    out <== in[0];
  } else if (n == 2) {
    min = Min();
    min.a <== in[0];
    min.b <== in[1];
    out <== min.out;
  } else {
    min2 = Min();
    multimin = MultiMin(n-1);
    for (var i = 0; i < n-1; i++) {
      multimin.in[i] <== in[i];
    }
    min2.a <== multimin.out;
    min2.b <== in[n-1];
    out <== min2.out;
  }
}

template matElemMin (m, n) {
  signal input a[m][n];
  signal output out;
  component colMins[m];
  component rowMin;

  for (var i = 0; i < m; i++) {
    colMins[i] = MultiMin(n);
    for (var j = 0; j < n; j++) {
      colMins[i].in[j] <== a[i][j];
    }
  }

  rowMin = MultiMin(m);
  for (var i = 0; i < m; i++) {
    rowMin.in[i] <== colMins[i].out;
  }
  out <== rowMin.out;
}

template matElemAdd (m,n) {
    signal input a[m][n];
    signal input b[m][n];
    signal output out[m][n];

    for (var i=0; i < m; i++) {
        for (var j=0; j < n; j++) {
            out[i][j] <== a[i][j] + b[i][j];
        }
    }
}

// sum of all elements in a matrix
template matElemSum (m,n) {
    signal input a[m][n];
    signal output out;

    signal sum[m*n];
    sum[0] <== a[0][0];
    var idx = 0;

    for (var i=0; i < m; i++) {
        for (var j=0; j < n; j++) {
            if (idx > 0) {
                sum[idx] <== sum[idx-1] + a[i][j];
            }
            idx++;
        }
    }

    out <== sum[m*n-1];
}

// matrix multiplication by element
template matElemMul (m,n) {
    signal input a[m][n];
    signal input b[m][n];
    signal output out[m][n];

    for (var i=0; i < m; i++) {
        for (var j=0; j < n; j++) {
            out[i][j] <== a[i][j] * b[i][j];
        }
    }
}

// Computes min of (a0 + b0, a1 + b1, ..., an + bn) for each elements
template matMin (m,n,p) {
    signal input a[m][n];
    signal input b[n][p];
    signal output out[m][p];

    component matElemMinComp[m][p];
    component matElemAddComp[m][p];

    for (var i=0; i < m; i++) {
        for (var j=0; j < p; j++) {
            matElemMinComp[i][j] = matElemMin(1,n);
            matElemAddComp[i][j] = matElemAdd(1,n);
            for (var k=0; k < n; k++) {
                matElemAddComp[i][j].a[0][k] <== a[i][k];
                matElemAddComp[i][j].b[0][k] <== b[k][j];
            }
            for (var k=0; k < n; k++) {
                matElemMinComp[i][j].a[0][k] <== matElemAddComp[i][j].out[0][k];
            }
            out[i][j] <== matElemMinComp[i][j].out;
        }
    }
}

template ShortestPath(n, steps) {
  signal input adj[n][n];
  signal output out[n][n];

  signal inter[steps][n][n];
  component matMinComp[steps];

  matMinComp[0] = matMin(n,n,n);
  matMinComp[0].a <== adj;
  matMinComp[0].b <== adj;

  for (var i = 1; i < steps; i++) {
    matMinComp[i] = matMin(n,n,n);
    matMinComp[i].a <== matMinComp[i-1].out;
    matMinComp[i].b <== matMinComp[i-1].out;
  }
  out <== matMinComp[steps-1].out;
}

template BellmanFord(n) {
  signal input vertices[n];
  signal input edgeSrc[n*n];
  signal input edgeDst[n*n];
  signal input weights[n*n];
  signal input source;
  signal intermediate[n][n][n];
  signal intermediatePred[n][n][n];
  signal output distances[n];

  var dists[n];
  var preds[n];

  for (var i = 0; i < n; i++) {
    dists[i] = 10000000000000;
    preds[i] = -1;
  }

  dists[source] = 0;

  // get number of vertices
  //var nVertices = size(vertices);
  //var nEdges = size(edgeSrc);

  for (var i = 0; i < n-1; i++) {
    for (var j = 0; j < n; j++) {
      var u = edgeSrc[j];
      var v = edgeDst[j];
      var w = weights[j];

      intermediate[i][j][v] <== dists[u] + w;
      intermediatePred[i][j][v] <== u;

      if (dists[v] > dists[u] + w) {
        dists[v] = dists[u] + w;
        preds[v] = u;
      }
    }
  }

  for (var i = 0; i < n ; i++) {
    distances[i] <-- dists[i];
  }
}

//component main {public [vertices, edgeSrc, edgeDst, weights, source]} = BellmanFord(32);
component main {public [adj]} = ShortestPath(16, 3);
//component main {public [in]} = test(32);
//component main {public [adj]} = BellmanFord(32);
