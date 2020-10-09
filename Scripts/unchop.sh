COVID_GFA_UNCHOPPED=data/relabeledSeqs.sorted_by_quality_and_len.g6.gfa
COVID_GFA_CHOPPED=data/relabeledSeqs.sorted_by_quality_and_len.g6.unchop.gfa

# unchop
odgi build -g $COVID_GFA_UNCHOPPED -o - | \
    odgi unchop -i - -o - | \
    odgi view -i - -g > $COVID_GFA_CHOPPED
