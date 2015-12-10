"""
for i in xrange(48):
    print "    assign dot_product[%d] = dot_product_f[%d*42 +: 42];" % (i,i);

for i in xrange(48):
    print "    assign normalizer[%d] = normalizer_f[%d*32 +: 32];" % (i,i);

for i in xrange(48):
    print "    assign correlation_f[%d*10 +: 10] = correlation[%d];" % (i,i);
"""
for i in xrange(48):
    print "    assign dot_product_f[%d*42 +: 42] = dot_product[%d];" % (i,i);

for i in xrange(48):
    print "    assign normalizer_f[%d*32 +: 32] = normalizer[%d];" % (i,i);

for i in xrange(48):
    print "    assign correlation[%d] = correlation_f[%d*10 +: 10];" % (i,i);

for i in xrange(48):
    print "defparam pcorrelate_gen[%d].pc.VHEIGHT = %d;" % (i,i)