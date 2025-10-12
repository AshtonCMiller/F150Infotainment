#include <QObject>

class SpotifyController : public QObject
{
    Q_OBJECT
public:
    explicit SpotifyController(QObject *parent = nullptr);

signals:
};
