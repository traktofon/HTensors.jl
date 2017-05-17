using HTensors

t1 = HTensorNode(rand(10,4))
t2 = HTensorNode(rand(5,5,6))
t3 = HTensorNode(rand(8,3))
t4 = HTensorNode(rand(11,4))
t12 = HTensorNode(rand(4,6,7), [t1,t2])
t34 = HTensorNode(rand(3,4,5), [t3,t4])
t1234 = HTensorNode(rand(7,5,10), [t12,t34])

