#! /usr/bin/python
import matplotlib.pyplot as plt
from math import sqrt, cos, sin, pi, atan2

print("hoop intersection")

paris1 =  (48.86945741152459,2.3264408111572266)
paris2 =  (48.87081237174292,2.3315048217773438)
paris3 =  (48.86762251107506,2.3310327529907227)
paris4 =  (48.872957650380556,2.3272132873535156)

hoopRadius = 350
earthRadius = 6371000

def sphericalToCartesian(coordinate):

    latD, lonD = coordinate

    latR = latD * pi / 180.0
    lonR = lonD * pi / 180.0

    return (earthRadius * cos(latR) * cos(lonR), 6371000 * cos(latR) * sin(lonR))

def circleIntersection(circle1, circle2):

    x1,y1,r1 = circle1
    x2,y2,r2 = circle2

    dx,dy = x2-x1,y2-y1
    d = sqrt(dx*dx+dy*dy)
    if d > r1+r2:
        print "#1"
        return None # no solutions, the circles are separate
    if d < abs(r1-r2):
        print "#2"
        return None # no solutions because one circle is contained within the other
    if d == 0 and r1 == r2:
        print "#3"
        return None # circles are coincident and there are an infinite number of solutions

    a = (r1*r1-r2*r2+d*d)/(2*d)
    h = sqrt(r1*r1-a*a)
    xm = x1 + a*dx/d
    ym = y1 + a*dy/d
    xs1 = xm + h*dy/d
    xs2 = xm - h*dy/d
    ys1 = ym - h*dx/d
    ys2 = ym + h*dx/d

    return (xs1,ys1),(xs2,ys2)

def distance(point1, point2):

    (x1, x1) = point1
    (x2, x2) = point2

    return sqrt( (max(x1,x2)-min(x1,x2))**2 + (max(y1,y2)-min(y1,y2))**2 )

def separate(points):

    x = []
    y = []

    for point in points:
        x.append(point[0])
        y.append(point[1])

    return (x,y)

hoopCentersShp = [paris1,paris2,paris3,paris4]


hoopCentersCart = []
hoopIntersectionsCart = []

hoopAreaBarycenter = (0,0)

for hoopCenter in hoopCentersShp:
    (x,y) = sphericalToCartesian(hoopCenter)
    hoopAreaBarycenter = (hoopAreaBarycenter[0]+x,hoopAreaBarycenter[1]+y)
    hoopCentersCart.append((x,y))

hoopAreaBarycenter = (hoopAreaBarycenter[0]/len(hoopCentersCart),hoopAreaBarycenter[1]/len(hoopCentersCart))

# sort them by rising angle
hoopCentersCart = sorted(hoopCentersCart, key=lambda center: atan2((center[1]-hoopAreaBarycenter[1]),(center[0]-hoopAreaBarycenter[0])))

for index in range(len(hoopCentersCart)):
    (x1,y1) = hoopCentersCart[index]
    if index+1 < len(hoopCentersCart):
        (x2,y2) = hoopCentersCart[index+1]
    else:
        (x2,y2) = hoopCentersCart[0]
    (inter1, inter2) = circleIntersection((x1,y1,hoopRadius),(x2,y2,hoopRadius))
    if distance(inter1,hoopAreaBarycenter) > distance(inter2,hoopAreaBarycenter):
        hoopIntersectionsCart.append(inter1)
    else:
        hoopIntersectionsCart.append(inter2)

(xcenter,ycenter) = separate(hoopCentersCart)
(xinter,yinter) = separate(hoopIntersectionsCart)

circles = []

fig, ax = plt.subplots()

for hoopCenter in hoopCentersCart:
    ax.add_artist(plt.Circle(hoopCenter, hoopRadius, color='b'))

plt.plot(xcenter,ycenter, 'yo')
plt.plot(xinter,yinter, 'ro')
plt.plot(hoopAreaBarycenter[0],hoopAreaBarycenter[1], 'ko')
mult = 3
plt.axis([hoopAreaBarycenter[0] - hoopRadius*mult,\
         hoopAreaBarycenter[0] + hoopRadius*mult,\
         hoopAreaBarycenter[1] - hoopRadius*mult,\
         hoopAreaBarycenter[1] + hoopRadius*mult])
plt.show()

print(len(hoopCentersCart))
print(len(hoopIntersectionsCart))