# memsafe
A module that aims for memory safe tables

Important: This module uses *Weak Values* and not weak keys! Only values are being gced from the table.

Relies on parent to gcollect values, if such value is an instance and has no parent, it's going to get gcollected.

Has an optional size to maximize the size of the table.