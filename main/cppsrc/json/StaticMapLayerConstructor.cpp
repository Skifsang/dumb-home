#include "StaticMapLayerConstructor.h"
#include <stdexcept>
#include "../map/StaticMapObjectImpl.h"

StaticMapLayerConstructor::StaticMapLayerConstructor(const int width, const int height) :
    grid()
{
    for (int horIndex = 0; horIndex < width; horIndex++)
    {
        grid.append(QVector<bool>());
        for (int verIndex = 0; verIndex < height; verIndex++)
        {
            grid[horIndex].append(false);
        }
    }
}

void StaticMapLayerConstructor::markCell(const int x, const int y)
{
    const int width = grid.size();
    const int height = grid[0].size();

    if (x < 0 || width <= x
        || y < 0 || height <= y)
    {
        throw std::invalid_argument("static object is out of bounds");
    }

    grid[x][y] = true;
}

StaticMapLayer * StaticMapLayerConstructor::construct() const
{
    QVector<QVector<QSharedPointer<StaticMapObject>>> staticObjects;

    for (int horIndex = 0; horIndex < grid.size(); horIndex++)
    {
        staticObjects.append(QVector<QSharedPointer<StaticMapObject>>());
        for (int verIndex = 0; verIndex < grid[0].size(); verIndex++)
        {
            if (grid[horIndex][verIndex] == true)
            {
                staticObjects[horIndex].append(QSharedPointer<StaticMapObject>(new StaticMapObjectImpl()));
            }
            else
            {
                staticObjects[horIndex].append(QSharedPointer<StaticMapObject>(nullptr));
            }
        }
    }

    return new StaticMapLayer(staticObjects);
}
