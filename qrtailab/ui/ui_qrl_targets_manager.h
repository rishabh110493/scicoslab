/********************************************************************************
** Form generated from reading UI file 'qrl_targets_manager.ui'
**
** Created by: Qt User Interface Compiler version 4.8.6
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_QRL_TARGETS_MANAGER_H
#define UI_QRL_TARGETS_MANAGER_H

#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtGui/QApplication>
#include <QtGui/QButtonGroup>
#include <QtGui/QCheckBox>
#include <QtGui/QDialog>
#include <QtGui/QGridLayout>
#include <QtGui/QGroupBox>
#include <QtGui/QHBoxLayout>
#include <QtGui/QHeaderView>
#include <QtGui/QLabel>
#include <QtGui/QLineEdit>
#include <QtGui/QListWidget>
#include <QtGui/QPushButton>
#include <QtGui/QSpacerItem>
#include <QtGui/QTabWidget>
#include <QtGui/QTableWidget>
#include <QtGui/QTextEdit>
#include <QtGui/QVBoxLayout>
#include <QtGui/QWidget>

QT_BEGIN_NAMESPACE

class Ui_QRL_TargetsManager
{
public:
    QGridLayout *gridLayout;
    QTabWidget *tabWidgetet;
    QWidget *tab;
    QGridLayout *gridLayout_2;
    QListWidget *listWidget;
    QPushButton *pushButton_4;
    QGroupBox *groupBox;
    QGridLayout *gridLayout_3;
    QLabel *label_9;
    QLineEdit *lineEdit;
    QCheckBox *checkBox_3;
    QCheckBox *checkBox;
    QCheckBox *checkBox_2;
    QLineEdit *lineEdit_2;
    QPushButton *pushButton_2;
    QPushButton *pushButton;
    QPushButton *pushButton_3;
    QGroupBox *groupBox_3;
    QGridLayout *gridLayout_10;
    QLabel *label_10;
    QLineEdit *targetNameLineEdit;
    QLabel *label_11;
    QTextEdit *textEdit;
    QLabel *label_12;
    QLineEdit *targetStatusLineEdit;
    QWidget *tab_2;
    QGridLayout *gridLayout_7;
    QGroupBox *targetGroupBox;
    QGridLayout *gridLayout_5;
    QLabel *targetNameLabel;
    QLineEdit *targetNameLineEdit_2;
    QGroupBox *statusGroupBox;
    QGridLayout *gridLayout_8;
    QLabel *targetConnectedLabel;
    QLabel *targetRunningLabel;
    QGroupBox *hartRTGroupBox;
    QGridLayout *gridLayout1;
    QCheckBox *scopesHRTCheckBox;
    QCheckBox *logsHRTCheckBox;
    QCheckBox *aLogsHRTCheckBox;
    QSpacerItem *verticalSpacer;
    QGroupBox *connectGroupBox;
    QGridLayout *gridLayout_6;
    QGroupBox *targetParameterGroupBox;
    QGridLayout *gridLayout_9;
    QVBoxLayout *vboxLayout;
    QHBoxLayout *hboxLayout;
    QLineEdit *ipLineEdit;
    QLabel *ipLabel;
    QHBoxLayout *hboxLayout1;
    QLineEdit *taskLineEdit;
    QLabel *taskLabel;
    QHBoxLayout *hboxLayout2;
    QLineEdit *scopeLineEdit;
    QLabel *scopeLabel;
    QHBoxLayout *hboxLayout3;
    QLineEdit *logLineEdit;
    QLabel *logLabel;
    QHBoxLayout *hboxLayout4;
    QLineEdit *alogLineEdit;
    QLabel *ALogLabel;
    QHBoxLayout *hboxLayout5;
    QLineEdit *ledLineEdit;
    QLabel *ledLabel;
    QHBoxLayout *hboxLayout6;
    QLineEdit *meterLineEdit;
    QLabel *meterLabel;
    QHBoxLayout *hboxLayout7;
    QLineEdit *synchLineEdit;
    QLabel *synchLabel;
    QPushButton *connectPushButton;
    QPushButton *startPushButton;
    QPushButton *stopPushButton;
    QPushButton *disconnectPushButton;
    QWidget *Seite;
    QGridLayout *gridLayout_4;
    QTableWidget *targetTableWidget;
    QHBoxLayout *hboxLayout8;
    QSpacerItem *spacerItem;
    QPushButton *helpButton;
    QSpacerItem *spacerItem1;
    QPushButton *closeButton;

    void setupUi(QDialog *QRL_TargetsManager)
    {
        if (QRL_TargetsManager->objectName().isEmpty())
            QRL_TargetsManager->setObjectName(QString::fromUtf8("QRL_TargetsManager"));
        QRL_TargetsManager->setEnabled(true);
        QRL_TargetsManager->resize(611, 520);
        QRL_TargetsManager->setMinimumSize(QSize(303, 228));
        QIcon icon;
        icon.addFile(QString::fromUtf8(":/icons/connect_icon.xpm"), QSize(), QIcon::Normal, QIcon::Off);
        QRL_TargetsManager->setWindowIcon(icon);
        gridLayout = new QGridLayout(QRL_TargetsManager);
        gridLayout->setObjectName(QString::fromUtf8("gridLayout"));
        tabWidgetet = new QTabWidget(QRL_TargetsManager);
        tabWidgetet->setObjectName(QString::fromUtf8("tabWidgetet"));
        tab = new QWidget();
        tab->setObjectName(QString::fromUtf8("tab"));
        gridLayout_2 = new QGridLayout(tab);
        gridLayout_2->setObjectName(QString::fromUtf8("gridLayout_2"));
        listWidget = new QListWidget(tab);
        listWidget->setObjectName(QString::fromUtf8("listWidget"));
        listWidget->setEnabled(false);

        gridLayout_2->addWidget(listWidget, 0, 0, 1, 2);

        pushButton_4 = new QPushButton(tab);
        pushButton_4->setObjectName(QString::fromUtf8("pushButton_4"));
        pushButton_4->setEnabled(false);
        pushButton_4->setAutoDefault(false);

        gridLayout_2->addWidget(pushButton_4, 0, 2, 1, 1);

        groupBox = new QGroupBox(tab);
        groupBox->setObjectName(QString::fromUtf8("groupBox"));
        groupBox->setEnabled(false);
        gridLayout_3 = new QGridLayout(groupBox);
        gridLayout_3->setObjectName(QString::fromUtf8("gridLayout_3"));
        label_9 = new QLabel(groupBox);
        label_9->setObjectName(QString::fromUtf8("label_9"));

        gridLayout_3->addWidget(label_9, 0, 0, 1, 1);

        lineEdit = new QLineEdit(groupBox);
        lineEdit->setObjectName(QString::fromUtf8("lineEdit"));

        gridLayout_3->addWidget(lineEdit, 1, 0, 1, 2);

        checkBox_3 = new QCheckBox(groupBox);
        checkBox_3->setObjectName(QString::fromUtf8("checkBox_3"));

        gridLayout_3->addWidget(checkBox_3, 2, 0, 1, 2);

        checkBox = new QCheckBox(groupBox);
        checkBox->setObjectName(QString::fromUtf8("checkBox"));

        gridLayout_3->addWidget(checkBox, 3, 0, 1, 1);

        checkBox_2 = new QCheckBox(groupBox);
        checkBox_2->setObjectName(QString::fromUtf8("checkBox_2"));

        gridLayout_3->addWidget(checkBox_2, 4, 0, 1, 1);

        lineEdit_2 = new QLineEdit(groupBox);
        lineEdit_2->setObjectName(QString::fromUtf8("lineEdit_2"));

        gridLayout_3->addWidget(lineEdit_2, 4, 1, 1, 1);

        pushButton_2 = new QPushButton(groupBox);
        pushButton_2->setObjectName(QString::fromUtf8("pushButton_2"));
        pushButton_2->setAutoDefault(false);

        gridLayout_3->addWidget(pushButton_2, 5, 0, 1, 2);


        gridLayout_2->addWidget(groupBox, 0, 3, 2, 1);

        pushButton = new QPushButton(tab);
        pushButton->setObjectName(QString::fromUtf8("pushButton"));
        pushButton->setEnabled(false);
        pushButton->setAutoDefault(false);

        gridLayout_2->addWidget(pushButton, 1, 0, 1, 1);

        pushButton_3 = new QPushButton(tab);
        pushButton_3->setObjectName(QString::fromUtf8("pushButton_3"));
        pushButton_3->setEnabled(false);
        pushButton_3->setAutoDefault(false);

        gridLayout_2->addWidget(pushButton_3, 1, 1, 1, 1);

        groupBox_3 = new QGroupBox(tab);
        groupBox_3->setObjectName(QString::fromUtf8("groupBox_3"));
        gridLayout_10 = new QGridLayout(groupBox_3);
        gridLayout_10->setObjectName(QString::fromUtf8("gridLayout_10"));
        label_10 = new QLabel(groupBox_3);
        label_10->setObjectName(QString::fromUtf8("label_10"));

        gridLayout_10->addWidget(label_10, 0, 0, 1, 1);

        targetNameLineEdit = new QLineEdit(groupBox_3);
        targetNameLineEdit->setObjectName(QString::fromUtf8("targetNameLineEdit"));
        targetNameLineEdit->setReadOnly(true);

        gridLayout_10->addWidget(targetNameLineEdit, 0, 1, 1, 1);

        label_11 = new QLabel(groupBox_3);
        label_11->setObjectName(QString::fromUtf8("label_11"));
        label_11->setEnabled(false);

        gridLayout_10->addWidget(label_11, 0, 2, 1, 1);

        textEdit = new QTextEdit(groupBox_3);
        textEdit->setObjectName(QString::fromUtf8("textEdit"));
        textEdit->setEnabled(false);

        gridLayout_10->addWidget(textEdit, 0, 3, 2, 1);

        label_12 = new QLabel(groupBox_3);
        label_12->setObjectName(QString::fromUtf8("label_12"));

        gridLayout_10->addWidget(label_12, 1, 0, 1, 1);

        targetStatusLineEdit = new QLineEdit(groupBox_3);
        targetStatusLineEdit->setObjectName(QString::fromUtf8("targetStatusLineEdit"));
        targetStatusLineEdit->setEnabled(true);
        targetStatusLineEdit->setReadOnly(true);

        gridLayout_10->addWidget(targetStatusLineEdit, 1, 1, 1, 1);


        gridLayout_2->addWidget(groupBox_3, 2, 0, 1, 4);

        tabWidgetet->addTab(tab, QString());
        tab_2 = new QWidget();
        tab_2->setObjectName(QString::fromUtf8("tab_2"));
        gridLayout_7 = new QGridLayout(tab_2);
        gridLayout_7->setObjectName(QString::fromUtf8("gridLayout_7"));
        targetGroupBox = new QGroupBox(tab_2);
        targetGroupBox->setObjectName(QString::fromUtf8("targetGroupBox"));
        gridLayout_5 = new QGridLayout(targetGroupBox);
        gridLayout_5->setObjectName(QString::fromUtf8("gridLayout_5"));
        targetNameLabel = new QLabel(targetGroupBox);
        targetNameLabel->setObjectName(QString::fromUtf8("targetNameLabel"));

        gridLayout_5->addWidget(targetNameLabel, 0, 0, 1, 1);

        targetNameLineEdit_2 = new QLineEdit(targetGroupBox);
        targetNameLineEdit_2->setObjectName(QString::fromUtf8("targetNameLineEdit_2"));
        targetNameLineEdit_2->setReadOnly(true);

        gridLayout_5->addWidget(targetNameLineEdit_2, 0, 1, 1, 1);

        statusGroupBox = new QGroupBox(targetGroupBox);
        statusGroupBox->setObjectName(QString::fromUtf8("statusGroupBox"));
        gridLayout_8 = new QGridLayout(statusGroupBox);
        gridLayout_8->setObjectName(QString::fromUtf8("gridLayout_8"));
        targetConnectedLabel = new QLabel(statusGroupBox);
        targetConnectedLabel->setObjectName(QString::fromUtf8("targetConnectedLabel"));

        gridLayout_8->addWidget(targetConnectedLabel, 1, 0, 1, 1);

        targetRunningLabel = new QLabel(statusGroupBox);
        targetRunningLabel->setObjectName(QString::fromUtf8("targetRunningLabel"));

        gridLayout_8->addWidget(targetRunningLabel, 1, 1, 1, 1);


        gridLayout_5->addWidget(statusGroupBox, 1, 0, 1, 2);

        hartRTGroupBox = new QGroupBox(targetGroupBox);
        hartRTGroupBox->setObjectName(QString::fromUtf8("hartRTGroupBox"));
        hartRTGroupBox->setEnabled(true);
        hartRTGroupBox->setCheckable(false);
        gridLayout1 = new QGridLayout(hartRTGroupBox);
        gridLayout1->setObjectName(QString::fromUtf8("gridLayout1"));
        scopesHRTCheckBox = new QCheckBox(hartRTGroupBox);
        scopesHRTCheckBox->setObjectName(QString::fromUtf8("scopesHRTCheckBox"));
        scopesHRTCheckBox->setChecked(true);

        gridLayout1->addWidget(scopesHRTCheckBox, 0, 0, 1, 1);

        logsHRTCheckBox = new QCheckBox(hartRTGroupBox);
        logsHRTCheckBox->setObjectName(QString::fromUtf8("logsHRTCheckBox"));
        logsHRTCheckBox->setChecked(true);

        gridLayout1->addWidget(logsHRTCheckBox, 1, 0, 1, 1);

        aLogsHRTCheckBox = new QCheckBox(hartRTGroupBox);
        aLogsHRTCheckBox->setObjectName(QString::fromUtf8("aLogsHRTCheckBox"));
        aLogsHRTCheckBox->setChecked(true);

        gridLayout1->addWidget(aLogsHRTCheckBox, 2, 0, 1, 1);


        gridLayout_5->addWidget(hartRTGroupBox, 4, 1, 1, 1);

        verticalSpacer = new QSpacerItem(20, 40, QSizePolicy::Minimum, QSizePolicy::Expanding);

        gridLayout_5->addItem(verticalSpacer, 4, 0, 1, 1);

        targetNameLabel->raise();
        targetNameLineEdit_2->raise();
        statusGroupBox->raise();
        hartRTGroupBox->raise();

        gridLayout_7->addWidget(targetGroupBox, 0, 1, 1, 1);

        connectGroupBox = new QGroupBox(tab_2);
        connectGroupBox->setObjectName(QString::fromUtf8("connectGroupBox"));
        connectGroupBox->setEnabled(true);
        gridLayout_6 = new QGridLayout(connectGroupBox);
        gridLayout_6->setObjectName(QString::fromUtf8("gridLayout_6"));
        targetParameterGroupBox = new QGroupBox(connectGroupBox);
        targetParameterGroupBox->setObjectName(QString::fromUtf8("targetParameterGroupBox"));
        targetParameterGroupBox->setEnabled(true);
        gridLayout_9 = new QGridLayout(targetParameterGroupBox);
        gridLayout_9->setObjectName(QString::fromUtf8("gridLayout_9"));
        vboxLayout = new QVBoxLayout();
#ifndef Q_OS_MAC
        vboxLayout->setSpacing(6);
#endif
#ifndef Q_OS_MAC
        vboxLayout->setContentsMargins(0, 0, 0, 0);
#endif
        vboxLayout->setObjectName(QString::fromUtf8("vboxLayout"));
        hboxLayout = new QHBoxLayout();
#ifndef Q_OS_MAC
        hboxLayout->setSpacing(6);
#endif
#ifndef Q_OS_MAC
        hboxLayout->setContentsMargins(0, 0, 0, 0);
#endif
        hboxLayout->setObjectName(QString::fromUtf8("hboxLayout"));
        ipLineEdit = new QLineEdit(targetParameterGroupBox);
        ipLineEdit->setObjectName(QString::fromUtf8("ipLineEdit"));

        hboxLayout->addWidget(ipLineEdit);

        ipLabel = new QLabel(targetParameterGroupBox);
        ipLabel->setObjectName(QString::fromUtf8("ipLabel"));

        hboxLayout->addWidget(ipLabel);


        vboxLayout->addLayout(hboxLayout);

        hboxLayout1 = new QHBoxLayout();
#ifndef Q_OS_MAC
        hboxLayout1->setSpacing(6);
#endif
        hboxLayout1->setContentsMargins(0, 0, 0, 0);
        hboxLayout1->setObjectName(QString::fromUtf8("hboxLayout1"));
        taskLineEdit = new QLineEdit(targetParameterGroupBox);
        taskLineEdit->setObjectName(QString::fromUtf8("taskLineEdit"));

        hboxLayout1->addWidget(taskLineEdit);

        taskLabel = new QLabel(targetParameterGroupBox);
        taskLabel->setObjectName(QString::fromUtf8("taskLabel"));

        hboxLayout1->addWidget(taskLabel);


        vboxLayout->addLayout(hboxLayout1);

        hboxLayout2 = new QHBoxLayout();
#ifndef Q_OS_MAC
        hboxLayout2->setSpacing(6);
#endif
        hboxLayout2->setContentsMargins(0, 0, 0, 0);
        hboxLayout2->setObjectName(QString::fromUtf8("hboxLayout2"));
        scopeLineEdit = new QLineEdit(targetParameterGroupBox);
        scopeLineEdit->setObjectName(QString::fromUtf8("scopeLineEdit"));

        hboxLayout2->addWidget(scopeLineEdit);

        scopeLabel = new QLabel(targetParameterGroupBox);
        scopeLabel->setObjectName(QString::fromUtf8("scopeLabel"));

        hboxLayout2->addWidget(scopeLabel);


        vboxLayout->addLayout(hboxLayout2);

        hboxLayout3 = new QHBoxLayout();
#ifndef Q_OS_MAC
        hboxLayout3->setSpacing(6);
#endif
        hboxLayout3->setContentsMargins(0, 0, 0, 0);
        hboxLayout3->setObjectName(QString::fromUtf8("hboxLayout3"));
        logLineEdit = new QLineEdit(targetParameterGroupBox);
        logLineEdit->setObjectName(QString::fromUtf8("logLineEdit"));

        hboxLayout3->addWidget(logLineEdit);

        logLabel = new QLabel(targetParameterGroupBox);
        logLabel->setObjectName(QString::fromUtf8("logLabel"));

        hboxLayout3->addWidget(logLabel);


        vboxLayout->addLayout(hboxLayout3);

        hboxLayout4 = new QHBoxLayout();
#ifndef Q_OS_MAC
        hboxLayout4->setSpacing(6);
#endif
        hboxLayout4->setContentsMargins(0, 0, 0, 0);
        hboxLayout4->setObjectName(QString::fromUtf8("hboxLayout4"));
        alogLineEdit = new QLineEdit(targetParameterGroupBox);
        alogLineEdit->setObjectName(QString::fromUtf8("alogLineEdit"));

        hboxLayout4->addWidget(alogLineEdit);

        ALogLabel = new QLabel(targetParameterGroupBox);
        ALogLabel->setObjectName(QString::fromUtf8("ALogLabel"));

        hboxLayout4->addWidget(ALogLabel);


        vboxLayout->addLayout(hboxLayout4);

        hboxLayout5 = new QHBoxLayout();
#ifndef Q_OS_MAC
        hboxLayout5->setSpacing(6);
#endif
        hboxLayout5->setContentsMargins(0, 0, 0, 0);
        hboxLayout5->setObjectName(QString::fromUtf8("hboxLayout5"));
        ledLineEdit = new QLineEdit(targetParameterGroupBox);
        ledLineEdit->setObjectName(QString::fromUtf8("ledLineEdit"));

        hboxLayout5->addWidget(ledLineEdit);

        ledLabel = new QLabel(targetParameterGroupBox);
        ledLabel->setObjectName(QString::fromUtf8("ledLabel"));

        hboxLayout5->addWidget(ledLabel);


        vboxLayout->addLayout(hboxLayout5);

        hboxLayout6 = new QHBoxLayout();
#ifndef Q_OS_MAC
        hboxLayout6->setSpacing(6);
#endif
        hboxLayout6->setContentsMargins(0, 0, 0, 0);
        hboxLayout6->setObjectName(QString::fromUtf8("hboxLayout6"));
        meterLineEdit = new QLineEdit(targetParameterGroupBox);
        meterLineEdit->setObjectName(QString::fromUtf8("meterLineEdit"));

        hboxLayout6->addWidget(meterLineEdit);

        meterLabel = new QLabel(targetParameterGroupBox);
        meterLabel->setObjectName(QString::fromUtf8("meterLabel"));

        hboxLayout6->addWidget(meterLabel);


        vboxLayout->addLayout(hboxLayout6);

        hboxLayout7 = new QHBoxLayout();
#ifndef Q_OS_MAC
        hboxLayout7->setSpacing(6);
#endif
        hboxLayout7->setContentsMargins(0, 0, 0, 0);
        hboxLayout7->setObjectName(QString::fromUtf8("hboxLayout7"));
        synchLineEdit = new QLineEdit(targetParameterGroupBox);
        synchLineEdit->setObjectName(QString::fromUtf8("synchLineEdit"));

        hboxLayout7->addWidget(synchLineEdit);

        synchLabel = new QLabel(targetParameterGroupBox);
        synchLabel->setObjectName(QString::fromUtf8("synchLabel"));

        hboxLayout7->addWidget(synchLabel);


        vboxLayout->addLayout(hboxLayout7);


        gridLayout_9->addLayout(vboxLayout, 0, 0, 1, 1);


        gridLayout_6->addWidget(targetParameterGroupBox, 0, 0, 5, 1);

        connectPushButton = new QPushButton(connectGroupBox);
        connectPushButton->setObjectName(QString::fromUtf8("connectPushButton"));
        connectPushButton->setEnabled(true);
        connectPushButton->setAutoDefault(false);
        connectPushButton->setDefault(true);

        gridLayout_6->addWidget(connectPushButton, 0, 1, 1, 1);

        startPushButton = new QPushButton(connectGroupBox);
        startPushButton->setObjectName(QString::fromUtf8("startPushButton"));
        startPushButton->setEnabled(false);
        startPushButton->setAutoDefault(false);

        gridLayout_6->addWidget(startPushButton, 1, 1, 1, 1);

        stopPushButton = new QPushButton(connectGroupBox);
        stopPushButton->setObjectName(QString::fromUtf8("stopPushButton"));
        stopPushButton->setEnabled(false);
        stopPushButton->setAutoDefault(false);

        gridLayout_6->addWidget(stopPushButton, 2, 1, 1, 1);

        disconnectPushButton = new QPushButton(connectGroupBox);
        disconnectPushButton->setObjectName(QString::fromUtf8("disconnectPushButton"));
        disconnectPushButton->setEnabled(false);
        disconnectPushButton->setAutoDefault(false);

        gridLayout_6->addWidget(disconnectPushButton, 3, 1, 1, 1);


        gridLayout_7->addWidget(connectGroupBox, 0, 0, 1, 1);

        tabWidgetet->addTab(tab_2, QString());
        Seite = new QWidget();
        Seite->setObjectName(QString::fromUtf8("Seite"));
        gridLayout_4 = new QGridLayout(Seite);
        gridLayout_4->setObjectName(QString::fromUtf8("gridLayout_4"));
        targetTableWidget = new QTableWidget(Seite);
        targetTableWidget->setObjectName(QString::fromUtf8("targetTableWidget"));

        gridLayout_4->addWidget(targetTableWidget, 0, 0, 1, 1);

        tabWidgetet->addTab(Seite, QString());

        gridLayout->addWidget(tabWidgetet, 0, 0, 1, 1);

        hboxLayout8 = new QHBoxLayout();
        hboxLayout8->setObjectName(QString::fromUtf8("hboxLayout8"));
        spacerItem = new QSpacerItem(16, 27, QSizePolicy::Expanding, QSizePolicy::Minimum);

        hboxLayout8->addItem(spacerItem);

        helpButton = new QPushButton(QRL_TargetsManager);
        helpButton->setObjectName(QString::fromUtf8("helpButton"));
        helpButton->setAutoDefault(false);

        hboxLayout8->addWidget(helpButton);

        spacerItem1 = new QSpacerItem(16, 27, QSizePolicy::Expanding, QSizePolicy::Minimum);

        hboxLayout8->addItem(spacerItem1);

        closeButton = new QPushButton(QRL_TargetsManager);
        closeButton->setObjectName(QString::fromUtf8("closeButton"));
        closeButton->setAutoDefault(false);

        hboxLayout8->addWidget(closeButton);


        gridLayout->addLayout(hboxLayout8, 1, 0, 1, 1);

#ifndef QT_NO_SHORTCUT
        ipLabel->setBuddy(ipLineEdit);
        taskLabel->setBuddy(taskLineEdit);
        scopeLabel->setBuddy(scopeLineEdit);
        logLabel->setBuddy(logLineEdit);
        ALogLabel->setBuddy(alogLineEdit);
        ledLabel->setBuddy(ledLineEdit);
        meterLabel->setBuddy(meterLineEdit);
        synchLabel->setBuddy(synchLineEdit);
#endif // QT_NO_SHORTCUT

        retranslateUi(QRL_TargetsManager);
        QObject::connect(closeButton, SIGNAL(clicked()), QRL_TargetsManager, SLOT(hide()));

        tabWidgetet->setCurrentIndex(1);


        QMetaObject::connectSlotsByName(QRL_TargetsManager);
    } // setupUi

    void retranslateUi(QDialog *QRL_TargetsManager)
    {
        QRL_TargetsManager->setWindowTitle(QApplication::translate("QRL_TargetsManager", "Targets Manager", 0, QApplication::UnicodeUTF8));
        pushButton_4->setText(QApplication::translate("QRL_TargetsManager", ">>", 0, QApplication::UnicodeUTF8));
        groupBox->setTitle(QApplication::translate("QRL_TargetsManager", "Start local Target", 0, QApplication::UnicodeUTF8));
        label_9->setText(QApplication::translate("QRL_TargetsManager", "Target", 0, QApplication::UnicodeUTF8));
        checkBox_3->setText(QApplication::translate("QRL_TargetsManager", "auto. connect", 0, QApplication::UnicodeUTF8));
        checkBox->setText(QApplication::translate("QRL_TargetsManager", "wait", 0, QApplication::UnicodeUTF8));
        checkBox_2->setText(QApplication::translate("QRL_TargetsManager", "stop after", 0, QApplication::UnicodeUTF8));
        pushButton_2->setText(QApplication::translate("QRL_TargetsManager", "Start Target", 0, QApplication::UnicodeUTF8));
        pushButton->setText(QApplication::translate("QRL_TargetsManager", "Add Target", 0, QApplication::UnicodeUTF8));
        pushButton_3->setText(QApplication::translate("QRL_TargetsManager", "Remove", 0, QApplication::UnicodeUTF8));
        groupBox_3->setTitle(QApplication::translate("QRL_TargetsManager", "Status", 0, QApplication::UnicodeUTF8));
        label_10->setText(QApplication::translate("QRL_TargetsManager", "Target", 0, QApplication::UnicodeUTF8));
        label_11->setText(QApplication::translate("QRL_TargetsManager", "Output:", 0, QApplication::UnicodeUTF8));
        label_12->setText(QApplication::translate("QRL_TargetsManager", "Status:", 0, QApplication::UnicodeUTF8));
        targetStatusLineEdit->setText(QApplication::translate("QRL_TargetsManager", "not running", 0, QApplication::UnicodeUTF8));
        tabWidgetet->setTabText(tabWidgetet->indexOf(tab), QApplication::translate("QRL_TargetsManager", "Start Target", 0, QApplication::UnicodeUTF8));
        targetGroupBox->setTitle(QApplication::translate("QRL_TargetsManager", "Target", 0, QApplication::UnicodeUTF8));
        targetNameLabel->setText(QApplication::translate("QRL_TargetsManager", "Name", 0, QApplication::UnicodeUTF8));
        statusGroupBox->setTitle(QApplication::translate("QRL_TargetsManager", "Status", 0, QApplication::UnicodeUTF8));
        targetConnectedLabel->setText(QApplication::translate("QRL_TargetsManager", "not connected", 0, QApplication::UnicodeUTF8));
        targetRunningLabel->setText(QApplication::translate("QRL_TargetsManager", "not running", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        hartRTGroupBox->setToolTip(QApplication::translate("QRL_TargetsManager", "Can only changed at startup.", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        hartRTGroupBox->setTitle(QApplication::translate("QRL_TargetsManager", "hard real time mode", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        scopesHRTCheckBox->setToolTip(QApplication::translate("QRL_TargetsManager", "Let the scope threads run in hard real time mode. \n"
"Can block the cpu, if to many data are transmitted.\n"
"\n"
" Important for the saving process. Prevent saving from blocking and data loss.", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        scopesHRTCheckBox->setText(QApplication::translate("QRL_TargetsManager", "Scopes", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        logsHRTCheckBox->setToolTip(QApplication::translate("QRL_TargetsManager", "Let the log threads run in hard real time mode. \n"
"Can block the cpu, if to many data are transmitted.\n"
"\n"
" Important for the saving process. Prevent saving from blocking and data loss.", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        logsHRTCheckBox->setText(QApplication::translate("QRL_TargetsManager", "Logs", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        aLogsHRTCheckBox->setToolTip(QApplication::translate("QRL_TargetsManager", "Let the scope threads run in hard real time mode. \n"
"Can block the cpu, if to many data are transmitted.\n"
"\n"
" Important for the saving process. Prevent saving from blocking and data loss.", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        aLogsHRTCheckBox->setText(QApplication::translate("QRL_TargetsManager", "ALogs", 0, QApplication::UnicodeUTF8));
        connectGroupBox->setTitle(QApplication::translate("QRL_TargetsManager", "Connect to Target", 0, QApplication::UnicodeUTF8));
        targetParameterGroupBox->setTitle(QApplication::translate("QRL_TargetsManager", "Parameter", 0, QApplication::UnicodeUTF8));
        ipLineEdit->setText(QApplication::translate("QRL_TargetsManager", "127.0.0.1", 0, QApplication::UnicodeUTF8));
        ipLabel->setText(QApplication::translate("QRL_TargetsManager", "IP Adress", 0, QApplication::UnicodeUTF8));
        taskLineEdit->setText(QApplication::translate("QRL_TargetsManager", "IFTASK", 0, QApplication::UnicodeUTF8));
        taskLabel->setText(QApplication::translate("QRL_TargetsManager", "Task Identifier", 0, QApplication::UnicodeUTF8));
        scopeLineEdit->setText(QApplication::translate("QRL_TargetsManager", "RTS", 0, QApplication::UnicodeUTF8));
        scopeLabel->setText(QApplication::translate("QRL_TargetsManager", "Scope Identifier", 0, QApplication::UnicodeUTF8));
        logLineEdit->setText(QApplication::translate("QRL_TargetsManager", "RTL", 0, QApplication::UnicodeUTF8));
        logLabel->setText(QApplication::translate("QRL_TargetsManager", "Log Identifier", 0, QApplication::UnicodeUTF8));
        alogLineEdit->setText(QApplication::translate("QRL_TargetsManager", "RAL", 0, QApplication::UnicodeUTF8));
        ALogLabel->setText(QApplication::translate("QRL_TargetsManager", "Alog Identifier", 0, QApplication::UnicodeUTF8));
        ledLineEdit->setText(QApplication::translate("QRL_TargetsManager", "RTE", 0, QApplication::UnicodeUTF8));
        ledLabel->setText(QApplication::translate("QRL_TargetsManager", "Led Identifier", 0, QApplication::UnicodeUTF8));
        meterLineEdit->setText(QApplication::translate("QRL_TargetsManager", "RTM", 0, QApplication::UnicodeUTF8));
        meterLabel->setText(QApplication::translate("QRL_TargetsManager", "Meter Identifier", 0, QApplication::UnicodeUTF8));
        synchLineEdit->setText(QApplication::translate("QRL_TargetsManager", "RTY", 0, QApplication::UnicodeUTF8));
        synchLabel->setText(QApplication::translate("QRL_TargetsManager", "Synch Identifier", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        connectPushButton->setToolTip(QApplication::translate("QRL_TargetsManager", "Connect to a target with the given task identifier at the given IP adress.", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        connectPushButton->setText(QApplication::translate("QRL_TargetsManager", "Connect", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        startPushButton->setToolTip(QApplication::translate("QRL_TargetsManager", "If the target is waiting, then it can be started be clicking the button.", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        startPushButton->setText(QApplication::translate("QRL_TargetsManager", "start", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        stopPushButton->setToolTip(QApplication::translate("QRL_TargetsManager", "Stops the target and disconnect.", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        stopPushButton->setText(QApplication::translate("QRL_TargetsManager", "stop", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        disconnectPushButton->setToolTip(QApplication::translate("QRL_TargetsManager", "Disconnect from the target, but the target is still running.", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        disconnectPushButton->setText(QApplication::translate("QRL_TargetsManager", "Disconnect", 0, QApplication::UnicodeUTF8));
        tabWidgetet->setTabText(tabWidgetet->indexOf(tab_2), QApplication::translate("QRL_TargetsManager", "Connect to Target", 0, QApplication::UnicodeUTF8));
        tabWidgetet->setTabText(tabWidgetet->indexOf(Seite), QApplication::translate("QRL_TargetsManager", "Target Elements", 0, QApplication::UnicodeUTF8));
        helpButton->setText(QApplication::translate("QRL_TargetsManager", "Help", 0, QApplication::UnicodeUTF8));
        closeButton->setText(QApplication::translate("QRL_TargetsManager", "close", 0, QApplication::UnicodeUTF8));
    } // retranslateUi

};

namespace Ui {
    class QRL_TargetsManager: public Ui_QRL_TargetsManager {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_QRL_TARGETS_MANAGER_H
