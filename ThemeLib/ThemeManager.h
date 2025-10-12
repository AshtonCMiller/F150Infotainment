#pragma once
#include <QObject>
#include <QColor>
#include <QVariantMap>


#if defined(THEMELIB_LIBRARY)
#  define THEMELIB_EXPORT Q_DECL_EXPORT
#else
#  define THEMELIB_EXPORT Q_DECL_IMPORT
#endif

class THEMELIB_EXPORT ThemeManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantMap colors READ colors NOTIFY colorsChanged)
    Q_PROPERTY(bool darkMode READ darkMode WRITE setDarkMode NOTIFY darkModeChanged)

public:
    explicit ThemeManager(QObject *parent = nullptr);

    // Accessors
    QVariantMap colors() const { return m_colors; }

    bool darkMode() const { return m_darkMode; }
    void setDarkMode(bool enabled);

signals:
    void colorsChanged();
    void darkModeChanged();

private:
    void updateColors();

    bool m_darkMode;
    QVariantMap m_colors;  // Semantic color map
};
