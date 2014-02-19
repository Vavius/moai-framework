#!/usr/bin/env python

import os, sys, re, argparse
import pprint
import collections


def writeLuaMesh(vbo, ibo):
    vbo_t = "{"
    for vtx in vbo:
        vbo_t += "%s,%s,%s,%s,%s,%s,%s,%s," % (vtx[0] + vtx[1] + vtx[2])
    vbo_t += '}'

    ibo_t = '{'
    for idx in ibo:
        ibo_t += "%s," % str(idx)
    ibo_t += '}'

    out = "{vbo = %s, ibo = %s}\n" % (vbo_t, ibo_t)

    return out

def packVBO(obj, groupName):
    vbo = OrderedSet()
    ibo = []
    
    groupFaces = obj['groups'][groupName]

    for face in groupFaces:
        for vtx in face:
            v_idx = int(vtx[0]) - 1
            uv_idx = int(vtx[1]) - 1
            vn_idx = int(vtx[2]) - 1
            v = obj['vertices'][v_idx]
            uv = obj['uv'][uv_idx]
            vn = obj['normals'][vn_idx]
            vtx_tuple = (v, vn, uv)
            vbo.add(vtx_tuple)
            ibo.append(vbo.index(vtx_tuple))

    return list(vbo), ibo

def readObj(input_file):
    """
    Returns dictionary representing 3D objects from obj file
    Dict format: 
        {   vertices : list, 
            uv : list, 
            groups : { 
                name : [(vtx_idx, uv_idx), (vtx_idx, uv_idx), (vtx_idx, uv_idx)]
            }
        }
    """
    global currentGroup
    currentGroup = None
    obj = {'vertices' : [], 'normals' : [], 'uv' : [], 'groups' : {}}

    def writeVertex(data):
        obj['vertices'].append(tuple(data[1:]))

    def writeNormal(data):
        obj['normals'].append(tuple(data[1:]))

    def writeUV(data):
        # flip v
        uv = data[1:]
        uv = [uv[0], str(1.0 - float(uv[1]))]
        obj['uv'].append(tuple(uv))

    def writeGroup(data):
        global currentGroup
        currentGroup = data[1]
        obj['groups'][currentGroup] = []

    def writeFace(data):
        global currentGroup
        if currentGroup is None:
            currentGroup = 'obj'
            obj['groups'][currentGroup] = []    
        face = [tuple(x.split('/')) for x in data[1:]]
        obj['groups'][currentGroup].append(tuple(face))

    commands = {
        'v' : writeVertex,
        'vn' : writeNormal,
        'vt' : writeUV,
        'g' : writeGroup,
        'f' : writeFace,
    }

    with open(input_file, "rU") as f:
        for line in f:
            s = [x.strip() for x in line.split()]
            if s and s[0] in commands:
                commands[s[0]](s)

    return obj

def fbxToMoaiMesh(input_file, output_file):
    obj = readObj(input_file)

    moai_code = "local objects = {}\n"
    pp = pprint.PrettyPrinter()
    for name in obj['groups']:
        if obj['groups'][name]:
            vbo, ibo = packVBO(obj, name)
            mesh = writeLuaMesh(vbo, ibo)
            moai_code += "objects.%s = %s\n" % (name, mesh)

    moai_code += "return objects"
    with open(output_file, "w") as f:
        f.write(moai_code)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-o', '--out', help="Output file", default = "mesh.lua")
    parser.add_argument('file', help="Input file in obj format")
    args = parser.parse_args()

    output_file = args.out
    input_file = args.file

    fbxToMoaiMesh(input_file, output_file)


class OrderedSet(collections.MutableSet):

    def __init__(self, iterable=None):
        self.end = end = [] 
        end += [None, end, end]         # sentinel node for doubly linked list
        self.map = {}                   # key --> [key, prev, next]
        if iterable is not None:
            self |= iterable

    def __len__(self):
        return len(self.map)

    def __contains__(self, key):
        return key in self.map

    def add(self, key):
        if key not in self.map:
            end = self.end
            curr = end[1]
            curr[2] = end[1] = self.map[key] = [key, curr, end]

    def index(self, elem):
        if elem in self.map:
            return next(i for i, e in enumerate(self) if e == elem)
        else:
            raise KeyError("That element isn't in the set")

    def discard(self, key):
        if key in self.map:        
            key, prev, next = self.map.pop(key)
            prev[2] = next
            next[1] = prev

    def __iter__(self):
        end = self.end
        curr = end[2]
        while curr is not end:
            yield curr[0]
            curr = curr[2]

    def __reversed__(self):
        end = self.end
        curr = end[1]
        while curr is not end:
            yield curr[0]
            curr = curr[1]

    def pop(self, last=True):
        if not self:
            raise KeyError('set is empty')
        key = self.end[1][0] if last else self.end[2][0]
        self.discard(key)
        return key

    def __repr__(self):
        if not self:
            return '%s()' % (self.__class__.__name__,)
        return '%s(%r)' % (self.__class__.__name__, list(self))

    def __eq__(self, other):
        if isinstance(other, OrderedSet):
            return len(self) == len(other) and list(self) == list(other)
        return set(self) == set(other)



if __name__ == '__main__':
    main()
