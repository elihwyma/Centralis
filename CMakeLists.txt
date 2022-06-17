cmake_minimum_required(VERSION 3.16)
project(Centralis LANGUAGES C CXX Swift)
add_subdirectory("../../" UIKit)

add_library(Centralis SHARED 
    ./Centralis/ViewController.swift
    ./Centralis/androidMain.swift
    ./Centralis/AppDelegate.swift
)

target_link_libraries(Centralis PRIVATE UIKit JNI SDL)