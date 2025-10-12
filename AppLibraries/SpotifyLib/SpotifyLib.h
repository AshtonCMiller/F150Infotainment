#include <QObject>

class SpotifyLib : public QObject
{
    Q_OBJECT
public:
    explicit SpotifyLib(QObject *parent = nullptr);

signals:
};
