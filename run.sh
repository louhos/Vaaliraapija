#!/bin/bash

scrapy crawl vaalirahoitusvalvonta.fi --set FEED_URI="aineisto/ennakkoilmoitus_%(time)s.csv" --set FEED_FORMAT=csv