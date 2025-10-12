#include <QObject>

class ThemeManager: public QObject
{
public:
    static ThemeManager* getThemeInstance();

    void loadTheme();
private:
    ThemeManager(QObject* parent = nullptr);
};
