/********************************************************************************
** Form generated from reading UI file 'qrl_main_window.ui'
**
** Created by: Qt User Interface Compiler version 4.8.6
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_QRL_MAIN_WINDOW_H
#define UI_QRL_MAIN_WINDOW_H

#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtGui/QApplication>
#include <QtGui/QButtonGroup>
#include <QtGui/QHeaderView>
#include <QtGui/QMainWindow>
#include <QtGui/QMenu>
#include <QtGui/QMenuBar>
#include <QtGui/QStatusBar>
#include <QtGui/QToolBar>
#include <QtGui/QWidget>

QT_BEGIN_NAMESPACE

class Ui_QRL_MainWindow
{
public:
    QAction *actionConnect;
    QAction *actionAbout_QRtaiLab;
    QAction *actionDisconnect;
    QAction *actionExit;
    QAction *actionStart;
    QAction *actionStop;
    QAction *actionShowMeter;
    QAction *actionShowScope;
    QAction *actionShowLed;
    QAction *actionShowParameter;
    QAction *actionLoadProfile;
    QAction *actionSaveProfile;
    QAction *actionDeleteProfile;
    QAction *actionStartTarget;
    QAction *actionShowLog;
    QAction *actionAbout_Qt;
    QWidget *centralwidget;
    QMenuBar *menubar;
    QMenu *menuView;
    QMenu *menuHelp;
    QMenu *menuTarget;
    QMenu *menuProject;
    QStatusBar *statusbar;
    QToolBar *toolBar;

    void setupUi(QMainWindow *QRL_MainWindow)
    {
        if (QRL_MainWindow->objectName().isEmpty())
            QRL_MainWindow->setObjectName(QString::fromUtf8("QRL_MainWindow"));
        QRL_MainWindow->resize(802, 579);
        QRL_MainWindow->setMinimumSize(QSize(0, 0));
        QRL_MainWindow->setSizeIncrement(QSize(50, 30));
        QRL_MainWindow->setAutoFillBackground(false);
        QRL_MainWindow->setAnimated(false);
        QRL_MainWindow->setDockOptions(QMainWindow::ForceTabbedDocks);
        actionConnect = new QAction(QRL_MainWindow);
        actionConnect->setObjectName(QString::fromUtf8("actionConnect"));
        QIcon icon;
        icon.addFile(QString::fromUtf8(":/icons/connect_icon.xpm"), QSize(), QIcon::Normal, QIcon::Off);
        actionConnect->setIcon(icon);
        actionAbout_QRtaiLab = new QAction(QRL_MainWindow);
        actionAbout_QRtaiLab->setObjectName(QString::fromUtf8("actionAbout_QRtaiLab"));
        actionDisconnect = new QAction(QRL_MainWindow);
        actionDisconnect->setObjectName(QString::fromUtf8("actionDisconnect"));
        actionDisconnect->setEnabled(true);
        QIcon icon1;
        icon1.addFile(QString::fromUtf8(":/icons/disconnect_icon.xpm"), QSize(), QIcon::Normal, QIcon::Off);
        actionDisconnect->setIcon(icon1);
        actionExit = new QAction(QRL_MainWindow);
        actionExit->setObjectName(QString::fromUtf8("actionExit"));
        QIcon icon2;
        icon2.addFile(QString::fromUtf8(":/icons/exit_icon.xpm"), QSize(), QIcon::Normal, QIcon::Off);
        actionExit->setIcon(icon2);
        actionStart = new QAction(QRL_MainWindow);
        actionStart->setObjectName(QString::fromUtf8("actionStart"));
        QIcon icon3;
        icon3.addFile(QString::fromUtf8(":/icons/start_icon.xpm"), QSize(), QIcon::Normal, QIcon::Off);
        actionStart->setIcon(icon3);
        actionStop = new QAction(QRL_MainWindow);
        actionStop->setObjectName(QString::fromUtf8("actionStop"));
        QIcon icon4;
        icon4.addFile(QString::fromUtf8(":/icons/stop_icon.xpm"), QSize(), QIcon::Normal, QIcon::Off);
        actionStop->setIcon(icon4);
        actionShowMeter = new QAction(QRL_MainWindow);
        actionShowMeter->setObjectName(QString::fromUtf8("actionShowMeter"));
        QIcon icon5;
        icon5.addFile(QString::fromUtf8(":/icons/meter_icon.xpm"), QSize(), QIcon::Normal, QIcon::Off);
        actionShowMeter->setIcon(icon5);
        actionShowScope = new QAction(QRL_MainWindow);
        actionShowScope->setObjectName(QString::fromUtf8("actionShowScope"));
        QIcon icon6;
        icon6.addFile(QString::fromUtf8(":/icons/scope_icon.xpm"), QSize(), QIcon::Normal, QIcon::Off);
        actionShowScope->setIcon(icon6);
        actionShowLed = new QAction(QRL_MainWindow);
        actionShowLed->setObjectName(QString::fromUtf8("actionShowLed"));
        QIcon icon7;
        icon7.addFile(QString::fromUtf8(":/icons/led_icon.xpm"), QSize(), QIcon::Normal, QIcon::Off);
        actionShowLed->setIcon(icon7);
        actionShowParameter = new QAction(QRL_MainWindow);
        actionShowParameter->setObjectName(QString::fromUtf8("actionShowParameter"));
        QIcon icon8;
        icon8.addFile(QString::fromUtf8(":/icons/parameters_icon.xpm"), QSize(), QIcon::Normal, QIcon::Off);
        actionShowParameter->setIcon(icon8);
        actionLoadProfile = new QAction(QRL_MainWindow);
        actionLoadProfile->setObjectName(QString::fromUtf8("actionLoadProfile"));
        QIcon icon9;
        icon9.addFile(QString::fromUtf8(":/icons/connect_profile_icon.xpm"), QSize(), QIcon::Normal, QIcon::Off);
        actionLoadProfile->setIcon(icon9);
        actionSaveProfile = new QAction(QRL_MainWindow);
        actionSaveProfile->setObjectName(QString::fromUtf8("actionSaveProfile"));
        QIcon icon10;
        icon10.addFile(QString::fromUtf8(":/icons/save_profile_icon.xpm"), QSize(), QIcon::Normal, QIcon::Off);
        actionSaveProfile->setIcon(icon10);
        actionDeleteProfile = new QAction(QRL_MainWindow);
        actionDeleteProfile->setObjectName(QString::fromUtf8("actionDeleteProfile"));
        QIcon icon11;
        icon11.addFile(QString::fromUtf8(":/icons/del_profile_icon.xpm"), QSize(), QIcon::Normal, QIcon::Off);
        actionDeleteProfile->setIcon(icon11);
        actionStartTarget = new QAction(QRL_MainWindow);
        actionStartTarget->setObjectName(QString::fromUtf8("actionStartTarget"));
        actionStartTarget->setCheckable(false);
        actionStartTarget->setEnabled(true);
        QIcon icon12;
        icon12.addFile(QString::fromUtf8(":/icons/session_open_icon.xpm"), QSize(), QIcon::Normal, QIcon::Off);
        actionStartTarget->setIcon(icon12);
        actionShowLog = new QAction(QRL_MainWindow);
        actionShowLog->setObjectName(QString::fromUtf8("actionShowLog"));
        QIcon icon13;
        icon13.addFile(QString::fromUtf8(":/icons/log_icon.xpm"), QSize(), QIcon::Normal, QIcon::Off);
        actionShowLog->setIcon(icon13);
        actionAbout_Qt = new QAction(QRL_MainWindow);
        actionAbout_Qt->setObjectName(QString::fromUtf8("actionAbout_Qt"));
        centralwidget = new QWidget(QRL_MainWindow);
        centralwidget->setObjectName(QString::fromUtf8("centralwidget"));
        QRL_MainWindow->setCentralWidget(centralwidget);
        menubar = new QMenuBar(QRL_MainWindow);
        menubar->setObjectName(QString::fromUtf8("menubar"));
        menubar->setGeometry(QRect(0, 0, 802, 28));
        menuView = new QMenu(menubar);
        menuView->setObjectName(QString::fromUtf8("menuView"));
        menuHelp = new QMenu(menubar);
        menuHelp->setObjectName(QString::fromUtf8("menuHelp"));
        menuTarget = new QMenu(menubar);
        menuTarget->setObjectName(QString::fromUtf8("menuTarget"));
        menuProject = new QMenu(menubar);
        menuProject->setObjectName(QString::fromUtf8("menuProject"));
        QRL_MainWindow->setMenuBar(menubar);
        statusbar = new QStatusBar(QRL_MainWindow);
        statusbar->setObjectName(QString::fromUtf8("statusbar"));
        QRL_MainWindow->setStatusBar(statusbar);
        toolBar = new QToolBar(QRL_MainWindow);
        toolBar->setObjectName(QString::fromUtf8("toolBar"));
        toolBar->setMinimumSize(QSize(0, 0));
        toolBar->setSizeIncrement(QSize(50, 30));
        toolBar->setOrientation(Qt::Horizontal);
        QRL_MainWindow->addToolBar(Qt::TopToolBarArea, toolBar);

        menubar->addAction(menuProject->menuAction());
        menubar->addAction(menuTarget->menuAction());
        menubar->addAction(menuView->menuAction());
        menubar->addAction(menuHelp->menuAction());
        menuView->addAction(actionShowParameter);
        menuView->addSeparator();
        menuView->addAction(actionShowScope);
        menuView->addAction(actionShowMeter);
        menuView->addAction(actionShowLed);
        menuHelp->addAction(actionAbout_Qt);
        menuHelp->addAction(actionAbout_QRtaiLab);
        menuTarget->addAction(actionStartTarget);
        menuTarget->addAction(actionConnect);
        menuTarget->addAction(actionDisconnect);
        menuTarget->addSeparator();
        menuTarget->addAction(actionStart);
        menuTarget->addAction(actionStop);
        menuProject->addAction(actionLoadProfile);
        menuProject->addAction(actionSaveProfile);
        menuProject->addAction(actionDeleteProfile);
        menuProject->addAction(actionExit);
        toolBar->addAction(actionExit);
        toolBar->addSeparator();
        toolBar->addAction(actionStartTarget);
        toolBar->addAction(actionConnect);
        toolBar->addAction(actionDisconnect);
        toolBar->addSeparator();
        toolBar->addAction(actionLoadProfile);
        toolBar->addAction(actionSaveProfile);
        toolBar->addAction(actionDeleteProfile);
        toolBar->addSeparator();
        toolBar->addAction(actionStart);
        toolBar->addAction(actionStop);
        toolBar->addSeparator();
        toolBar->addAction(actionShowParameter);
        toolBar->addSeparator();
        toolBar->addAction(actionShowScope);
        toolBar->addAction(actionShowMeter);
        toolBar->addAction(actionShowLed);
        toolBar->addAction(actionShowLog);

        retranslateUi(QRL_MainWindow);

        QMetaObject::connectSlotsByName(QRL_MainWindow);
    } // setupUi

    void retranslateUi(QMainWindow *QRL_MainWindow)
    {
        QRL_MainWindow->setWindowTitle(QApplication::translate("QRL_MainWindow", "QRtaiLab Graphical User Interface", 0, QApplication::UnicodeUTF8));
        actionConnect->setText(QApplication::translate("QRL_MainWindow", "Connect", 0, QApplication::UnicodeUTF8));
        actionAbout_QRtaiLab->setText(QApplication::translate("QRL_MainWindow", "About QRtaiLab", 0, QApplication::UnicodeUTF8));
        actionDisconnect->setText(QApplication::translate("QRL_MainWindow", "Disconnect", 0, QApplication::UnicodeUTF8));
        actionExit->setText(QApplication::translate("QRL_MainWindow", "&Quit", 0, QApplication::UnicodeUTF8));
        actionStart->setText(QApplication::translate("QRL_MainWindow", "Start", 0, QApplication::UnicodeUTF8));
        actionStop->setText(QApplication::translate("QRL_MainWindow", "Stop", 0, QApplication::UnicodeUTF8));
        actionShowMeter->setText(QApplication::translate("QRL_MainWindow", "Meter", 0, QApplication::UnicodeUTF8));
        actionShowScope->setText(QApplication::translate("QRL_MainWindow", "Scope", 0, QApplication::UnicodeUTF8));
        actionShowLed->setText(QApplication::translate("QRL_MainWindow", "Led", 0, QApplication::UnicodeUTF8));
        actionShowParameter->setText(QApplication::translate("QRL_MainWindow", "Parameter", 0, QApplication::UnicodeUTF8));
        actionLoadProfile->setText(QApplication::translate("QRL_MainWindow", "Load Profile", 0, QApplication::UnicodeUTF8));
        actionSaveProfile->setText(QApplication::translate("QRL_MainWindow", "Save Profile", 0, QApplication::UnicodeUTF8));
        actionDeleteProfile->setText(QApplication::translate("QRL_MainWindow", "Delete Profile", 0, QApplication::UnicodeUTF8));
        actionStartTarget->setText(QApplication::translate("QRL_MainWindow", "Target Manager", 0, QApplication::UnicodeUTF8));
        actionShowLog->setText(QApplication::translate("QRL_MainWindow", "Log", 0, QApplication::UnicodeUTF8));
        actionAbout_Qt->setText(QApplication::translate("QRL_MainWindow", "About &Qt", 0, QApplication::UnicodeUTF8));
        menuView->setTitle(QApplication::translate("QRL_MainWindow", "&View", 0, QApplication::UnicodeUTF8));
        menuHelp->setTitle(QApplication::translate("QRL_MainWindow", "&Help", 0, QApplication::UnicodeUTF8));
        menuTarget->setTitle(QApplication::translate("QRL_MainWindow", "&Target", 0, QApplication::UnicodeUTF8));
        menuProject->setTitle(QApplication::translate("QRL_MainWindow", "Project", 0, QApplication::UnicodeUTF8));
    } // retranslateUi

};

namespace Ui {
    class QRL_MainWindow: public Ui_QRL_MainWindow {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_QRL_MAIN_WINDOW_H
