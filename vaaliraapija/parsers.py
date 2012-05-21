# -*- coding: utf-8 -*-
"""
Created on Sun May 22 17:41:15 2011

@author: -
"""
import os
import yaml
import csv, codecs, cStringIO

def parsi_ehdokkaat(tiedosto):
    ''' Parsii valitut ehdokkaat sisältältävän tekstitiedoston ja palautta
    sanakirjan.
    '''
    # Lataa yaml-tiedosto
    stream = file(tiedosto, 'r')
    valitut_raaka = yaml.safe_load(stream)
    valitut_edustajat = []    
    
    # Käy jokainen vaalipiiri läpi ja erottele suku- ja etunimi sekä puolue
    # omiksi alkioikseen, tidostossa muotoa: "Tuomioja,Erkki;SDP"
    # muodosta uusi lista muotoa 
    #   ['sukunimi', 'etunimi', 'puolue', 'vaalipiiri']

    for vaalipiiri, ehdokkaat in valitut_raaka.iteritems():
        for ehdokas in ehdokkaat:
            try:            
                nimet, puolue = ehdokas.split(";")
                # Suku- ja etunimi on eroteltu pilkulla ","
                nimet = nimet.split(",")
                valitut_edustajat.append([nimet[0], nimet[1], puolue, 
                                          vaalipiiri])
            except ValueError, e:
                print("Virhe: %s, %s" % (ehdokas, vaalipiiri))
    
    return valitut_edustajat

class UTF8Recoder:
    """
    Iterator that reads an encoded stream and reencodes the input to UTF-8
    """
    def __init__(self, f, encoding):
        self.reader = codecs.getreader(encoding)(f)

    def __iter__(self):
        return self

    def next(self):
        return self.reader.next().encode("utf-8")

class UnicodeReader:
    """
    A CSV reader which will iterate over lines in the CSV file "f",
    which is encoded in the given encoding.
    """

    def __init__(self, f, dialect=csv.excel, encoding="utf-8", **kwds):
        f = UTF8Recoder(f, encoding)
        self.reader = csv.reader(f, dialect=dialect, **kwds)

    def next(self):
        row = self.reader.next()
        return [unicode(s, "utf-8") for s in row]

    def __iter__(self):
        return self

class UnicodeWriter:
    """
    A CSV writer which will write rows to CSV file "f",
    which is encoded in the given encoding.
    """

    def __init__(self, f, dialect=csv.excel, encoding="utf-8", **kwds):
        # Redirect output to a queue
        self.queue = cStringIO.StringIO()
        self.writer = csv.writer(self.queue, dialect=dialect, **kwds)
        self.stream = f
        self.encoder = codecs.getincrementalencoder(encoding)()

    def writerow(self, row):
        self.writer.writerow([s.encode("utf-8") for s in row])
        # Fetch UTF-8 output from the queue ...
        data = self.queue.getvalue()
        data = data.decode("utf-8")
        # ... and reencode it into the target encoding
        data = self.encoder.encode(data)
        # write to the target stream
        self.stream.write(data)
        # empty queue
        self.queue.truncate(0)

    def writerows(self, rows):
        for row in rows:
            self.writerow(row)

if __name__ == '__main__':
    ws = r"/home/jlehtoma/Dropbox/Code/vaalirahoitus/aineisto/"
    intiedosto = "valitut_edustajat.yaml"
    outtiedosto= "valitut_edustajat.csv"
    valitut_ehdokkaat = parsi_ehdokkaat(os.path.join(ws, intiedosto))
   
    with open(os.path.join(ws, outtiedosto), 'wb') as f:
        writer = csv.writer(f)
        writer.writerows(valitut_ehdokkaat)

    