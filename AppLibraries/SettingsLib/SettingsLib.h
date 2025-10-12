#include <QObject>

class SettingsLib : public QObject
{
    Q_OBJECT
public:
    explicit SettingsLib(QObject *parent = nullptr);

signals:
};
