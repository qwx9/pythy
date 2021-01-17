#exec(open("mkmatslowly.py").read())
import numpy as np
import scipy.sparse as ss
import json

# (from args) get start and end indices
index = 0
start = 0
end = 1

f = open("names.txt")
trk = [line[:-1] for line in f]
f.close()

mat = ss.csr_matrix((0,len(trk)), dtype=np.int8)
slc = start * 1000

for i in range(start, end):
	f = open(f"mpd.slice.{slc}-{slc+999}.json")
	j = json.load(f)
	f.close()
	m = np.zeros(shape=(1000,len(trk)), dtype=np.int8)
	for row in range(1000):
		pl = j["playlists"][row]
		t = (x["track_uri"] for x in pl["tracks"])
		m[row] = [int(x in t) for x in trk]
	slc += 1000
	mat = ss.vstack((mat, ss.csr_matrix(m)))
ss.save_npz("mat%02d.npz" % index, mat)
