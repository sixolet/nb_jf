## nb jf

Norns mod to add `nb` voices for Whimsical Raps Just Friends.

This mod adds eight voice targets:

* 6x mono voices. One for each output of Just Friends. These support slew.

* 1x unison voice. Uses all the Just Friends outputs to produce a detuned unison super-waveform. Adjustable detune.

* 1x poly voice. Uses the internal Just Friends voice allocation or alternative allocation modes. Has three params:
    * **trigger mode** controls whether a note will be released. gate mode will trigger a release on note off, trigger mode will not (same as how jf works in transient mode).
    * **alloc mode** has three options:
        * `jf` uses the just friends internal voice allocation (ii.jf.play_note), always using all six voices.
        * `rotate` will rotate between voices, within the range from 1 to `voice count`.
        * `random` will randomly select voices, within the range from 1 to `voice count`.
    * **voice count** allows dynamically changing the number of voices used in rotate and random allocation modes.

You can use as many different mono voices at once as you like. I will not be responsible for trying to use mono voices and other voices at the same time, or trying to use unison and poly at the same time. Seems like a silly idea.